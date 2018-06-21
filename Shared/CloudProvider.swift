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

public final class CloudProvider {

    public let containerID = "iCloud.com.netsplit.EngineShed"
    public let subscriptionID = "private-changes"
    public let zoneID = CKRecordZone.ID(zoneName: "EngineShed")

    public var container: CKContainer
    public var database: CKDatabase

    public var hasSubscription: Bool = false
    public var databaseServerChangeToken: CKServerChangeToken?
    public var zoneServerChangeToken: [CKRecordZone.ID: CKServerChangeToken?] = [:]

    public var persistentContainer: NSPersistentContainer

    public init(persistentContainer: NSPersistentContainer) {
        container = CKContainer(identifier: containerID)
        database = container.privateCloudDatabase

        self.persistentContainer = persistentContainer

        loadDefaults()

        // Subscribe to Core Data notifications to watch for changes.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsWillSave(notification:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: persistentContainer.viewContext)
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: persistentContainer.viewContext)
    }

    /// Load cached fields from UserDefaults.
    private func loadDefaults() {
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
    internal func saveDefaults() {
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

    /// Subscribe to changes in the zone.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    public func subscribeToChanges(completionHandler: @escaping (_ error: Error?) -> Void) {
        guard !hasSubscription else {
            completionHandler(nil)
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
                completionHandler(error)
            } else {
                self.hasSubscription = true
                completionHandler(nil)
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
    public func fetchChanges(completionHandler: @escaping (_ error: Error?) -> Void) {
        // Fetch the database changes since the last server change token.
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseServerChangeToken)
        operation.fetchAllChanges = true

        var changedZoneIDs: Set<CKRecordZone.ID> = []

        operation.recordZoneWithIDChangedBlock = { zoneID in
            print("Zone changed \(zoneID)")
            changedZoneIDs.insert(zoneID)

            // We always fetch changes for all zones since we track their change tokens; but if
            // this is a new zone, store `nil` for the key to ensure we fetch the contents of the
            // new zone.
            if self.zoneServerChangeToken.index(forKey: zoneID) == nil {
                self.zoneServerChangeToken.updateValue(nil, forKey: zoneID)
            }
        }

        operation.recordZoneWithIDWasDeletedBlock = { zoneID in
            print("Zone deleted \(zoneID)")

            fatalError("Not yet implemented")

            // TODO: delete the images from Models in this zone
            // TODO: delete all records in this zone

            if let index = self.zoneServerChangeToken.index(forKey: zoneID) {
                self.zoneServerChangeToken.remove(at: index)
            }

        }

        operation.changeTokenUpdatedBlock = { serverChangeToken in
            print("New change token \(serverChangeToken)")

            // TODO: Flush zone deletions for this database to disk

            self.databaseServerChangeToken = serverChangeToken
            self.saveDefaults()
        }

        operation.fetchDatabaseChangesCompletionBlock = { serverChangeToken, _, error in
            if let error = error {
                print("Fetch changes error \(error)")
                completionHandler(error)
            } else {
                print("Fetch changes completed \(serverChangeToken!)")

                // TODO: Flush zone deletions for this database to disk

                self.databaseServerChangeToken = serverChangeToken
                self.saveDefaults()

                // We can't use the actual set of changedZoneIDs because there is no connection
                // from database changes to zone changes. This means in case of a zone fetch error
                // we wouldn't know to try to refetch the zone. We also can't persist this, since
                // we don't know for a given zone fetch which database token it corresponds to.
                // So always just fetch changes for all zones. rdar://41256574
                let changedZoneIDs = Array(self.zoneServerChangeToken.keys)
                if !changedZoneIDs.isEmpty {
                    self.fetchZoneChanges(changedZoneIDs, completionHandler: completionHandler)
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
    public func fetchZoneChanges(_ changedZoneIDs: Array<CKRecordZone.ID>, completionHandler: @escaping (_ error: Error?) -> Void) {
        // Perform updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil

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

        operation.recordChangedBlock = { record in
            print("Record changed \(record)")
            print(record.changedKeys())

            do {
                try NSManagedObject.syncObjectFromRecord(record, in: context)
            } catch {
                // FIXME: abort this operation.
                fatalError("Failed \(error)")
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            print("Record deleted \(recordID) - \(recordType)")

            fatalError("Not yet implemented")

            // TODO: delete the image if this is a Model
            // TODO: delete the record
        }

        operation.recordZoneChangeTokensUpdatedBlock = { zoneID, serverChangeToken, _ in
            print("New zone change token \(zoneID) \(serverChangeToken!)")

            do {
                try context.save()
            } catch {
                // FIXME: abort this operation.
                fatalError("Save failed \(error)")
            }

            self.zoneServerChangeToken[zoneID] = serverChangeToken
            self.saveDefaults()
        }

        operation.recordZoneFetchCompletionBlock = { zoneID, serverChangeToken, _, _, error in
            if let error = error {
                print("Zone fetch error \(error)")
            } else {
                print("Zone fetch completed \(zoneID) \(serverChangeToken!)")

                do {
                    try context.save()
                } catch {
                    // FIXME: abort this operation.
                    fatalError("Save failed \(error)")
                }

                self.zoneServerChangeToken[zoneID] = serverChangeToken
                self.saveDefaults()
            }
        }

        operation.fetchRecordZoneChangesCompletionBlock = { error in
            if let error = error {
                print("Zone changes error \(error)")
                completionHandler(error)
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

        modifyRecords(recordsToSave: !saveRecords.isEmpty ? saveRecords : nil,
                      recordIDsToDelete: !deleteRecordIDs.isEmpty ? deleteRecordIDs : nil)

        pendingUpdates = nil
    }


    // MARK: Zone and record creation/updating

    var hasZone: Bool {
        return zoneServerChangeToken.index(forKey: zoneID) != nil
    }

    private func createZoneOperation() -> CKDatabaseOperation? {
        guard !hasZone else { return nil }

        let zone = CKRecordZone(zoneID: zoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = {
            savedZones, deletedZoneIDs, error in
            if let error = error {
                fatalError("Couldn't modify zone \(error)")
            }
//            completionHandler(error)
        }

        operation.qualityOfService = .utility
        database.add(operation)

        return operation
    }

    private func modifyRecords(recordsToSave: [CKRecord]?, recordIDsToDelete: [CKRecord.ID]?) {
        // Perform system field updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil

        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        operation.savePolicy = .ifServerRecordUnchanged

        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                fatalError("Couldn't modify records: \(error)")
            }

            if let savedRecords = savedRecords {
                debugPrint(savedRecords)
                do {
                    try self.updateSystemFields(records: savedRecords, in: context)
                } catch {
                    fatalError("Failed to write back: \(error)")
                }
            }

            if let deletedRecordIDs = deletedRecordIDs {
                debugPrint(deletedRecordIDs)
            }
        }

        if let zoneOperatation = createZoneOperation() {
            operation.addDependency(zoneOperatation)
        }

        operation.qualityOfService = .utility
        database.add(operation)
    }

    private func updateSystemFields(records: [CKRecord], in context: NSManagedObjectContext) throws {
        for record in records {
            try NSManagedObject.syncObjectFromRecord(record, in: context, updateValues: false)
        }

        try context.save()
    }

}
