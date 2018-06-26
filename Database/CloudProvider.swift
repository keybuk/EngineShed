//
//  CloudProvider.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import Dispatch

public final class CloudProvider {

    public let containerID = "iCloud.com.netsplit.EngineShed"
    public let subscriptionID = "private-changes"
    public let zoneID = CKRecordZone.ID(zoneName: "EngineShed")

    public var container: CKContainer
    public var database: CKDatabase

    var hasSubscription: Bool = false
    var databaseServerChangeToken: CKServerChangeToken?
    var zoneServerChangeToken: [CKRecordZone.ID: CKServerChangeToken?] = [:]

    public var persistentContainer: NSPersistentContainer

    var queue: DispatchQueue

    public init(persistentContainer: NSPersistentContainer) {
        container = CKContainer(identifier: containerID)
        database = container.privateCloudDatabase

        self.persistentContainer = persistentContainer

        queue = DispatchQueue(label: "com.netsplit.EngineShed.Database.CloudProvider")

        // Subscribe to Core Data notifications to watch for changes.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsWillSave(notification:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: persistentContainer.viewContext)
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: persistentContainer.viewContext)
    }

    /// Load cached fields from UserDefaults.
    func loadDefaults() {
        let defaults = UserDefaults.standard

        hasSubscription = defaults.bool(forKey: "HasSubscription")

        if let datas = defaults.array(forKey: "ServerChangeToken") as? [Data] {
            for data in datas {
                guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else { continue }

                let serverChangeToken = unarchiver.decodeObject(of: CKServerChangeToken.self, forKey: "ServerChangeToken")
                if let zoneID = unarchiver.decodeObject(of: CKRecordZone.ID.self, forKey: "ZoneID") {
                    zoneServerChangeToken.updateValue(serverChangeToken, forKey: zoneID)
                } else {
                    databaseServerChangeToken = serverChangeToken
                }

                unarchiver.finishDecoding()
            }
        }
    }

    /// Save cached fields from UserDefaults.
    func saveDefaults() {
        let defaults = UserDefaults.standard

        defaults.set(hasSubscription, forKey: "HasSubscription")

        var tokens: [(CKRecordZone.ID?, CKServerChangeToken?)] = []
        tokens.append((nil, databaseServerChangeToken))
        tokens.append(contentsOf: zoneServerChangeToken.map { ($0, $1) })

        let datas = tokens.map { (zoneID, serverChangeToken) -> Data in
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)

            if let zoneID = zoneID {
                archiver.encode(zoneID, forKey: "ZoneID")
            }
            if let serverChangeToken = serverChangeToken {
                archiver.encode(serverChangeToken, forKey: "ServerChangeToken")
            }
            archiver.finishEncoding()

            return archiver.encodedData
        }

        defaults.set(datas, forKey: "ServerChangeToken")
    }

    public func start() {
        loadDefaults()

        // Fetch and resume all of the long-lived operations.
        container.fetchAllLongLivedOperationIDs { (operationIDs, error) in
            if let error = error {
                print("Failed to fetch long-lived operations: \(error)")
            } else if let operationIDs = operationIDs {
                for operationID in operationIDs {
                    self.container.fetchLongLivedOperation(withID: operationID) { (operation, error) in
                        if let error = error {
                            print("Long-lived operation \(operationID) failed: \(error)")
                        } else if let operation = operation as? CKModifyRecordsOperation {
                            operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
                                if let error = error {
                                    print("Resuming long-lived modify operation \(operationID) failed: \(error)")
                                } else {
                                    self.handleModifyCompletion(savedRecords: savedRecords, deletedRecordIDs: deletedRecordIDs)
                                }
                            }

                            print("Resuming long-lived modify operation \(operationID)")
                            self.database.add(operation)
                        } else if let operation = operation {
                            print("Resuming long-lived operation \(operationID)")
                            self.container.add(operation)
                        }
                    }
                }
            }
        }
        
        subscribeToChanges()
        fetchChanges()
    }

    /// Subscribe to changes in the zone.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    public func subscribeToChanges(completionHandler: ((_ error: Error?) -> Void)? = nil) {
        guard !hasSubscription else {
            completionHandler?(nil)
            return
        }

        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)

        operation.modifySubscriptionsCompletionBlock = { savedSubscriptions, deletedSubscriptionIDs, error in
            if let error = error {
                print("Modify subscriptions error \(error)")
                completionHandler?(error)
            } else {
                self.hasSubscription = true
                completionHandler?(nil)
            }
        }

        operation.qualityOfService = .utility
        database.add(operation)
    }

    /// Handle a remote notification.
    ///
    /// - Parameters:
    ///   - userInfo: Notification dictionary.
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    public func handleRemoteNotification(_ userInfo: [AnyHashable : Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        if notification.subscriptionID == subscriptionID {
            fetchChanges(completionHandler: completionHandler)
        }
    }

    /// Fetch changes from the database.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    public func fetchChanges(completionHandler: ((_ error: Error?) -> Void)? = nil) {
        // Ensure that there is only ever one fetch operation going on at a time.
        queue.async {
            self.queue.suspend()
            self.internalFetchChanges { error in
                self.queue.resume()
                completionHandler?(error)
            }
        }
    }

    /// Fetch changes from the database.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    private func internalFetchChanges(completionHandler: @escaping (_ error: Error?) -> Void) {
        dispatchPrecondition(condition: .onQueue(queue))

        // Perform updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil

        // Collate deleted zones together so we can issue them as batch deletes; keep track of
        // changed zones in case we can use that information later.
        var deleteZoneIDs: [CKRecordZone.ID] = []
        var changedZoneIDs: Set<CKRecordZone.ID> = []

        // Fetch the database changes since the last server change token.
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseServerChangeToken)
        operation.fetchAllChanges = true

        // On error we cancel the operation and stash the error here, so we can return it to the
        // completion handler.
        var cancelCausedByError: Error? = nil

        operation.recordZoneWithIDChangedBlock = { zoneID in
            changedZoneIDs.insert(zoneID)

            // If this is a new zone store `nil` for the change token to receive all changes
            // in the zone, as well as the latest change token.
            if self.zoneServerChangeToken.index(forKey: zoneID) == nil {
                self.zoneServerChangeToken.updateValue(nil, forKey: zoneID)
            }
        }

        operation.recordZoneWithIDWasDeletedBlock = { zoneID in
            deleteZoneIDs.append(zoneID)

            if let index = self.zoneServerChangeToken.index(forKey: zoneID) {
                self.zoneServerChangeToken.remove(at: index)
            }
        }

        operation.recordZoneWithIDWasPurgedBlock = { zoneID in
            deleteZoneIDs.append(zoneID)

            // FIXME: if the zoneID is our primary zone, record that it was purged and do not recreate it or sync without user consent.
            if let index = self.zoneServerChangeToken.index(forKey: zoneID) {
                self.zoneServerChangeToken.remove(at: index)
            }
        }

        operation.changeTokenUpdatedBlock = { serverChangeToken in
            do {
                if !deleteZoneIDs.isEmpty {
                    try NSManagedObject.deleteObjectsForZoneIDs(deleteZoneIDs, in: context, mergeTo: self.persistentContainer.viewContext)
                    deleteZoneIDs.removeAll()
                }

                self.databaseServerChangeToken = serverChangeToken
                self.saveDefaults()
            } catch {
                print("Error deleting objects in deleted zones: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.fetchDatabaseChangesCompletionBlock = { serverChangeToken, _, error in
            if let error = error {
                if operation.isCancelled, let error = cancelCausedByError {
                    completionHandler(error)
                } else {
                    print("Database changes fetch error: \(error)")
                    completionHandler(error)
                }
            } else {
                do {
                    if !deleteZoneIDs.isEmpty {
                        try NSManagedObject.deleteObjectsForZoneIDs(deleteZoneIDs, in: context, mergeTo: self.persistentContainer.viewContext)
                        deleteZoneIDs.removeAll()
                    }

                    self.databaseServerChangeToken = serverChangeToken
                    self.saveDefaults()

                    // We can't use the actual set of changedZoneIDs because there is no connection
                    // from database changes to zone changes. This means in case of a zone fetch
                    // error we wouldn't know to try to refetch the zone. We also can't persist
                    // this, since we don't know for a given zone fetch which database token it
                    // corresponds to. So always just fetch changes for all zones. rdar://41256574
                    let changedZoneIDs = Array(self.zoneServerChangeToken.keys)
                    if !changedZoneIDs.isEmpty {
                        self.fetchZoneChanges(changedZoneIDs, completionHandler: completionHandler)
                    } else {
                        print("Database changes completed (no zones)")
                        completionHandler(nil)
                    }
                } catch {
                    print("Error deleting objects in deleted zones: \(error)")
                    completionHandler(error)
                }
            }
        }

        operation.qualityOfService = .utility
        database.add(operation)

    }

    /// Fetch zone changes from the database.
    ///
    /// - Parameters:
    ///   - changedZoneIDs: IDs of zones that have changed.
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    func fetchZoneChanges(_ changedZoneIDs: Array<CKRecordZone.ID>, completionHandler: @escaping (_ error: Error?) -> Void) {
        // Perform updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil

        // Collate deleted records together so we can issue them as batch deletes.
        var deletedRecords: [CKRecord.RecordType: [CKRecord.ID]] = [:]

        // Create a single operation to fetch changes to all zones, providing the appropriate
        // change token to each. In theory we only ever have one zone, but this should future-proof
        // the code for supporting sharing later on.
        let operation: CKFetchRecordZoneChangesOperation
        if #available(macOS 10.14, iOS 12.0, *) {
            let configurations = zoneServerChangeToken.mapValues {
                CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: $0, resultsLimit: nil, desiredKeys: nil)
            }

            operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: changedZoneIDs, configurationsByRecordZoneID: configurations)
        } else {
            let options = zoneServerChangeToken.mapValues { (serverChangeToken: CKServerChangeToken?) -> CKFetchRecordZoneChangesOperation.ZoneOptions in
                let zoneOptions = CKFetchRecordZoneChangesOperation.ZoneOptions()
                zoneOptions.previousServerChangeToken = serverChangeToken
                return zoneOptions
            }

            operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: changedZoneIDs, optionsByRecordZoneID: options)
        }
        operation.fetchAllChanges = true

        // On error we cancel the operation and stash the error here, so we can return it to the
        // completion handler.
        var cancelCausedByError: Error? = nil

        operation.recordChangedBlock = { record in
            do {
                try NSManagedObject.syncObjectFromRecord(record, in: context)
            } catch {
                print("Error synchronizing object: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            deletedRecords[recordType, default: []].append(recordID)
        }

        operation.recordZoneChangeTokensUpdatedBlock = { zoneID, serverChangeToken, _ in
            do {
                if !deletedRecords.isEmpty {
                    try NSManagedObject.deleteObjectsForRecords(deletedRecords, in: context, mergeTo: self.persistentContainer.viewContext)
                    deletedRecords.removeAll()
                }
                try context.save()

                self.zoneServerChangeToken[zoneID] = serverChangeToken
                self.saveDefaults()
            } catch {
                print("Error flushing zone changes: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.recordZoneFetchCompletionBlock = { zoneID, serverChangeToken, _, _, error in
            if let error = error as? CKError, error.code == .userDeletedZone {
                // FIXME: should do something here, but why did we not get the change from the database token?
                print("User deleted zone error")
            } else if let error = error {
                print("Zone changes fetch error: \(error)")
                cancelCausedByError = error
                operation.cancel()
            } else {
                do {
                    if !deletedRecords.isEmpty {
                        try NSManagedObject.deleteObjectsForRecords(deletedRecords, in: context, mergeTo: self.persistentContainer.viewContext)
                        deletedRecords.removeAll()
                    }
                    try context.save()

                    self.zoneServerChangeToken[zoneID] = serverChangeToken
                    self.saveDefaults()
                } catch {
                    print("Error flushing zone changes: \(error)")
                    cancelCausedByError = error
                    operation.cancel()
                }
            }
        }

        operation.fetchRecordZoneChangesCompletionBlock = { error in
            if let error = error {
                if operation.isCancelled, let error = cancelCausedByError {
                    completionHandler(error)
                } else {
                    print("Zone changes fetch completion error: \(error)")
                    completionHandler(error)
                }
            } else {
                print("Zone changes completed")
                completionHandler(nil)
            }
        }

        operation.qualityOfService = .utility
        database.add(operation)
    }

    // MARK: Core Data notifications

    /// Set of changed keys for each updated object.
    var pendingUpdates: [NSManagedObjectID: Set<String>]? = nil

    @objc
    func managedObjectContextObjectsWillSave(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }

        // Create CKRecord objects for newly inserted objects as part of the save action, rather
        // than after, so in the case of retry after a failure, we send an update for the same
        // object rather than duplicating it.
        for object in context.insertedObjects {
            if let storable = object as? CloudStorable {
                storable.createRecord(in: zoneID)
            }
        }

        // The set of changed keys is not available in DidSave, so save them here; but only the
        // keys because validation takes place between WillSave and DidSave.
        pendingUpdates = Dictionary(uniqueKeysWithValues: context.updatedObjects.map {
            ($0.objectID, Set($0.changedValues().keys))
        })
    }

    @objc
    func managedObjectContextObjectsDidSave(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        var saveRecords: [CKRecord] = []
        var deleteRecordIDs: [CKRecord.ID] = []

        // Save all of the keys of newly inserted objects that can be synchronized.
        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            for object in insertedObjects {
                if let storable = object as? CloudStorable,
                    let record = storable.syncToRecord(forKeys: nil)
                {
                    saveRecords.append(record)
                }
            }
        }

        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for object in updatedObjects {
                guard !object.isInserted else { fatalError("Object inserted and updated") }
                let changedKeys = pendingUpdates?[object.objectID]

                // Retrieve the set of changed keys recorded in the WillSave notification and
                // only update the record using those.
                if let storable = object as? CloudStorable,
                    let record = storable.syncToRecord(forKeys: changedKeys)
                {
                    saveRecords.append(record)
                }
            }
        }

        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for object in deletedObjects {
                guard !object.isInserted && !object.isUpdated else { fatalError("Object deleted and inserted or updated") }
                if let storable = object as? CloudStorable,
                    let recordID = storable.recordID
                {
                    deleteRecordIDs.append(recordID)
                }
            }
        }

        modifyRecords(recordsToSave: saveRecords, recordIDsToDelete: deleteRecordIDs)
        pendingUpdates = nil
    }


    // MARK: Zone and record creation/updating

    /// `true` if we believe the server has the primary zone for our records.
    var hasZone: Bool {
        return zoneServerChangeToken.index(forKey: zoneID) != nil
    }

    /// Create the primary zone for our records.
    func createZoneOperation() -> CKDatabaseOperation {
        // Create a zone modify operation for our primary zone, which should create it if needed.
        let zone = CKRecordZone(zoneID: zoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)

        operation.modifyRecordZonesCompletionBlock = {
            savedZones, deletedZoneIDs, error in
            if let error = error {
                // Errors creating the zone should end up appearing in the record modification,
                // so rather than bailing out, just move on.
                print("Modify zone error: \(error)")
            } else {
                // Record `nil` for the change token of any zone we created, until we find out
                // what the token really is later on.
                if let savedZones = savedZones {
                    for zone in savedZones {
                        if self.zoneServerChangeToken.index(forKey: zone.zoneID) == nil {
                            self.zoneServerChangeToken.updateValue(nil, forKey: zone.zoneID)
                        }
                    }
                }
            }
        }

        operation.qualityOfService = .utility
        database.add(operation)

        return operation
    }

    /// Send local object changes to the database.
    ///
    /// - Parameters:
    ///   - recordsToSave: CloudKit records to save.
    ///   - recordIDsToDelete: identifiers of CloudKit records to delete.
    func modifyRecords(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecord.ID]) {
        // Create a single operation to modify all of the records at once.
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        operation.savePolicy = .ifServerRecordUnchanged
        operation.configuration.isLongLived = true

        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error as? CKError,
                error.code == .limitExceeded
            {
                print("Limit exceeded, splitting request in half")
                let s = recordsToSave.count / 2
                let d = recordIDsToDelete.count / 2

                self.modifyRecords(recordsToSave: Array(recordsToSave[..<s]), recordIDsToDelete: Array(recordIDsToDelete[..<d]))
                self.modifyRecords(recordsToSave: Array(recordsToSave[s...]), recordIDsToDelete: Array(recordIDsToDelete[d...]))
            } else if let error = error {
                fatalError("Couldn't modify records: \(error)")
            }

            self.handleModifyCompletion(savedRecords: savedRecords, deletedRecordIDs: deletedRecordIDs)
        }

        // Create the primary zone before we modify records, but for performance reasons, only
        // do this if we don't think it exists.
        if !hasZone {
            let zoneOperation = createZoneOperation()
            operation.addDependency(zoneOperation)
        }

        operation.qualityOfService = .utility
        database.add(operation)
        print("Modify \(operation)")
    }

    /// Commit results of a modification to the database.
    ///
    /// - Parameters:
    ///   - savedRecords: CloudKit records that were saved.
    ///   - deletedRecordIDs: identifiers of CloudKit records that were deleted.
    func handleModifyCompletion(savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?) {
        // Perform system field updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil

        if let savedRecords = savedRecords {
            debugPrint(savedRecords)
            do {
                for record in savedRecords {
                    try NSManagedObject.syncObjectFromRecord(record, in: context, updateValues: false)
                }

                try context.save()
            } catch {
                fatalError("Failed to write back: \(error)")
            }
        }

        if let deletedRecordIDs = deletedRecordIDs {
            debugPrint(deletedRecordIDs)
        }
    }

}
