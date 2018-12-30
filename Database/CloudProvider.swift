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

    public let zoneID = CKRecordZone.ID(zoneName: "EngineShed")

    public var container: CKContainer
    public var database: CKDatabase
    public var persistentContainer: NSPersistentContainer

    public init(container: CKContainer, database: CKDatabase, persistentContainer: NSPersistentContainer) {
        self.container = container
        self.database = database
        self.persistentContainer = persistentContainer

        // Subscribe to Core Data notifications to watch for changes.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsWillSave(notification:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: persistentContainer.viewContext)
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: persistentContainer.viewContext)
    }

    public func start() {
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
            if let storable = object as? NSManagedObject & CloudStorable {
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
                if let storable = object as? NSManagedObject & CloudStorable,
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
                if let storable = object as? NSManagedObject & CloudStorable,
                    let record = storable.syncToRecord(forKeys: changedKeys)
                {
                    saveRecords.append(record)
                }
            }
        }

        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for object in deletedObjects {
                guard !object.isInserted && !object.isUpdated else { fatalError("Object deleted and inserted or updated") }
                if let storable = object as? NSManagedObject & CloudStorable,
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
//    var hasZone: Bool {
//        return zoneServerChangeToken.index(forKey: zoneID) != nil
//    }

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
//                if let savedZones = savedZones {
//                    for zone in savedZones {
//                        if self.zoneServerChangeToken.index(forKey: zone.zoneID) == nil {
//                            self.zoneServerChangeToken.updateValue(nil, forKey: zone.zoneID)
//                        }
//                    }
//                }
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
//        if !hasZone {
            let zoneOperation = createZoneOperation()
            operation.addDependency(zoneOperation)
//        }

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
