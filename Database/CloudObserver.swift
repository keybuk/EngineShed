//
//  CloudObserver.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/28/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import Dispatch

/// Observes changes to a database stored in CloudKit.
///
/// Changes can be polled at any time, and take place asynchronously on a background thread with
/// multiple requests queued serially:
///
///     cloudObserver.fetchChanges { error in
///         // Handle error
///     }
///
/// To use in a push manner, subscribe to changes at application startup:
///
///     cloudObserver.subscribeToChanges()
///
/// And then fetch changes on a remote notification:
///
///     cloudObserver.handleRemoteNotification(userInfo) { error in
///         // Handle error
///     }
///
/// The state for the synchronisation is stored in the local store, alongside the records. The
/// `DatabaseState` table holds the server change token for each database within the container,
/// keyed by the `databaseScope` raw value. The `ZoneState` table holds the server change token
/// for each record, keyed by the `zoneID`; along with flags as to whether the zone has pending
/// changes, is pending deletion, or has been purged.
///
/// Fetching changes is a two-step process. The first step fetches the database changes, and set
/// of changed and deleted zones. This stage is persisted to the store before moving to the second
/// step, which fetches the set of changed zones from the store, and then fetches the set of
/// changed and deleted records from the server in a single batch.
///
/// The `isDirty` flag for a zone is only cleared when the new server change token for the zone
/// is persisted, thus an error or crash etc. results in refetching the zone again, just in case,
/// even if all changes have already been applied.
///
/// # NSManagedObject Requirements
/// In order to make changes to the local store, this class makes three requirements on
/// `NSManagedObject`:
///  * `NSManagedObject.syncObjectFromRecord(:in:)`
///  * `NSManagedObject.deleteObjectsForZoneIDs(:in:mergeTo:)`
///  * `NSManagedObject.deleteObjectsForRecords(:in:mergeTo:)`
///
/// These are not type-aware; `NSManagedObject+StorableObjectTranslation` provides an implementation
/// that expands or iterates the real object types as long as they conform to `CloudStorable` and
/// calls methods there.
public final class CloudObserver {

    /// Database object being observed.
    public private(set) var database: CKDatabase

    /// Persistent container of local store.
    public private(set) var persistentContainer: NSPersistentContainer

    /// Label for dispatch queue to ensure serial operation.
    let queueLabel = "com.netsplit.EngineShed.Database.CloudObserver"

    /// Dispatch queue to manage serial operation.
    var queue: DispatchQueue

    /// Subscription identifier registered for notifications.
    let subscriptionID = "private-changes"

    public init(database: CKDatabase, persistentContainer: NSPersistentContainer) {
        self.database = database
        self.persistentContainer = persistentContainer

        queue = DispatchQueue(label: queueLabel)
    }

    /// Fetch changes from the database.
    ///
    /// This can be called at any time to check for changes in the database, and update the
    /// local store. Multiple concurrent calls are queued and executed in serial.
    /// `completionHandler` is optional, and is called when this queued fetch completes.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    public func fetchChanges(completionHandler: ((_ error: Error?) -> Void)? = nil) {
        // Ensure that there is only ever one fetch operation going on at a time.
        // `queue` is already a serial dispatch queue, the use of `suspend()` and `resume()` here
        // is to suspend the queue while we're waiting for asynchronous callbacks from the
        // database.
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
    /// Internal method called by `fetchChanges()` on `queue`.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    private func internalFetchChanges(completionHandler: @escaping (_ error: Error?) -> Void) {
        dispatchPrecondition(condition: .onQueue(queue))

        // Perform updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.overwrite
        context.undoManager = nil
        context.userInfo[CloudProvider.ignoreChangesKey] = true

        // Fetch or create the database state record.
        let databaseState: DatabaseState
        do {
            databaseState = try DatabaseState.fetchOrCreate(context: context, for: self.database)
        } catch {
            print("Error fetching database state: \(error)")
            completionHandler(error)
            return
        }

        // Fetch the database changes since the last server change token.
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseState.serverChangeToken)
        operation.fetchAllChanges = true

        // On error we cancel the operation and stash the error here, so we can return it to the
        // completion handler.
        var cancelCausedByError: Error? = nil

        operation.recordZoneWithIDChangedBlock = { zoneID in
            print("Zone changed: \(zoneID)")
            do {
                let zoneState = try databaseState.stateForZoneWithID(zoneID)
                zoneState.isDirty = true
            } catch {
                print("Error storing changed zone state: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.recordZoneWithIDWasDeletedBlock = { zoneID in
            print("Zone deleted: \(zoneID)")
            do {
                let zoneState = try databaseState.stateForZoneWithID(zoneID)
                zoneState.shouldDelete = true
            } catch {
                print("Error storing purged zone state: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.recordZoneWithIDWasPurgedBlock = { zoneID in
            print("Zone purged: \(zoneID)")
            do {
                let zoneState = try databaseState.stateForZoneWithID(zoneID)
                zoneState.shouldDelete = true
                zoneState.isPurged = true
            } catch {
                print("Error storing deleted zone state: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.changeTokenUpdatedBlock = { serverChangeToken in
            print("Database change token: \(serverChangeToken)")
            do {
                try self.performPendingZoneDeletions(from: databaseState, in: context)
                databaseState.serverChangeToken = serverChangeToken
                try context.save()
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
                print("Fetch database changes completed, token: \(serverChangeToken!)")
                do {
                    try self.performPendingZoneDeletions(from: databaseState, in: context)
                    databaseState.serverChangeToken = serverChangeToken
                    try context.save()

                    print("Database changes completed")
                    self.fetchZoneChanges(completionHandler: completionHandler)
                } catch {
                    print("Error deleting objects in deleted zones: \(error)")
                    completionHandler(error)
                }
            }
        }

        print("Begin fetch database changes")
        operation.qualityOfService = .utility
        database.add(operation)
    }

    /// Delete records stored in zones marked for deletion.
    ///
    /// Fetches the set of zones marked `shouldDelete`, and then performs a batch deletion, for
    /// each storable record type, of records marked as originating from each zone to be deleted.
    ///
    /// Once the deletion is complete, changes are merged back to the view context.
    ///
    /// - Parameters:
    ///   - databaseState: database sync state record on current context.
    ///   - context: background context to process deletion.
    private func performPendingZoneDeletions(from databaseState: DatabaseState, in context: NSManagedObjectContext) throws {
        let deleteZoneStates = try databaseState.statesForDeletedZones()
        let zoneIDs = deleteZoneStates.compactMap { $0.zoneID }
        print("\(zoneIDs.count) zones pending deletion")

        try NSManagedObject.deleteObjectsForZoneIDs(zoneIDs, in: context, mergeTo: persistentContainer.viewContext)

        // Preserve the ZoneState record if purged, otherwise clean up.
        for zoneState in deleteZoneStates {
            if zoneState.isPurged {
                zoneState.serverChangeToken = nil
                zoneState.shouldDelete = false
            } else {
                context.performAndWait {
                    context.delete(zoneState)
                }
            }
        }
    }

    /// Fetch zone changes from the database.
    ///
    /// Changes for all zones marked `isDirty` are fetched and records in the local store
    /// updated.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    private func fetchZoneChanges(completionHandler: @escaping (_ error: Error?) -> Void) {
        // Perform updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.overwrite
        context.undoManager = nil
        context.userInfo[CloudProvider.ignoreChangesKey] = true

        // Fetch or create the database state record, and set of dirty zones.
        let databaseState: DatabaseState
        let dirtyZoneStates: [ZoneState]
        do {
            databaseState = try DatabaseState.fetchOrCreate(context: context, for: self.database)
            dirtyZoneStates = try databaseState.statesForDirtyZones()
        } catch {
            print("Error fetching database state: \(error)")
            completionHandler(error)
            return
        }

        // Exit early if there are no zones with pending changes.
        if dirtyZoneStates.isEmpty {
            print("No zones with pending changes")
            completionHandler(nil)
            return
        } else {
            print("\(dirtyZoneStates.count) zones with changes")
        }

        // Create a single operation to fetch changes to all zones, providing the appropriate
        // change token to each. In theory we only ever have one zone, but this should future-proof
        // the code for supporting sharing later on.
        let configurations = Dictionary(uniqueKeysWithValues: dirtyZoneStates.map {
            ($0.zoneID!, CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: $0.serverChangeToken, resultsLimit: nil, desiredKeys: nil))
        })

        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: Array(configurations.keys), configurationsByRecordZoneID: configurations)
        operation.fetchAllChanges = true

        // Collate deleted records together so we can issue them as batch deletes.
        var deletedRecords: [CKRecord.RecordType: [CKRecord.ID]] = [:]

        // On error we cancel the operation and stash the error here, so we can return it to the
        // completion handler.
        var cancelCausedByError: Error? = nil

        operation.recordChangedBlock = { record in
            print("Record changed: \(record.recordID)")
            do {
                try NSManagedObject.syncObjectFromRecord(record, in: context)
            } catch {
                print("Error synchronizing object: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            print("Record deleted: \(recordID) \(recordType)")
            deletedRecords[recordType, default: []].append(recordID)
        }

        operation.recordZoneChangeTokensUpdatedBlock = { zoneID, serverChangeToken, _ in
            print("Record change token updated: \(zoneID) \(serverChangeToken!)")
            do {
                if !deletedRecords.isEmpty {
                    try NSManagedObject.deleteObjectsForRecords(deletedRecords, in: context, mergeTo: self.persistentContainer.viewContext)
                    deletedRecords.removeAll()
                }

                let zoneState = try databaseState.stateForZoneWithID(zoneID)
                zoneState.serverChangeToken = serverChangeToken
                try context.save()
            } catch {
                print("Error flushing zone changes: \(error)")
                cancelCausedByError = error
                operation.cancel()
            }
        }

        operation.recordZoneFetchCompletionBlock = { zoneID, serverChangeToken, _, _, error in
            if let error = error as? CKError, error.code == .userDeletedZone {
                // Why did we not get the change from the database token?
                print("User deleted zone error")
                do {
                    let zoneState = try databaseState.stateForZoneWithID(zoneID)
                    zoneState.shouldDelete = true
                    try context.save()
                } catch {
                    print("Error saving zone state: \(error)")
                    cancelCausedByError = error
                    operation.cancel()
                }
            } else if let error = error {
                print("Zone changes fetch error: \(error)")
                cancelCausedByError = error
                operation.cancel()
            } else {
                print("Zone fetch completed: \(zoneID) \(serverChangeToken!)")
                do {
                    if !deletedRecords.isEmpty {
                        try NSManagedObject.deleteObjectsForRecords(deletedRecords, in: context, mergeTo: self.persistentContainer.viewContext)
                        deletedRecords.removeAll()
                    }

                    let zoneState = try databaseState.stateForZoneWithID(zoneID)
                    zoneState.serverChangeToken = serverChangeToken
                    zoneState.isDirty = false
                    try context.save()
                } catch {
                    print("Error flushing zone changes: \(error)")
                    cancelCausedByError = error
                    operation.cancel()
                }
            }
        }

        operation.fetchRecordZoneChangesCompletionBlock = { error in
            print("Fetch zone changes completed")
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

        print("Begin fetch zone changes")
        operation.qualityOfService = .utility
        database.add(operation)
    }

    /// Subscribe to changes in the zone.
    ///
    /// This creates or updates the subscription record on the server. For efficiency purposes,
    /// once it's been verified that the server has the subscription, this is cached in the local
    /// defaults and this method will return immediately.
    ///
    /// - Parameters:
    ///   - completionHandler: called on completion.
    ///    - error: `nil` on success, error that occurred on failure.
    public func subscribeToChanges(completionHandler: ((_ error: Error?) -> Void)? = nil) {
        // Avoid repeatedly modifying the same subscription over and over once it's already
        // been handled once by this client. We use defaults for this since it's just a local cache
        // and safe to be forgotten, and avoids resource locking of the DatabaseState record with
        // the fetch we might run alongside.
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "HasSubscription") {
            completionHandler?(nil)
            return
        }

        // Create the subscription we want, and the operation to modify it.
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
                print("Subscription created")
                defaults.set(true, forKey: "HasSubscription")

                completionHandler?(nil)
            }
        }

        operation.qualityOfService = .utility
        database.add(operation)
    }

    /// Handle a remote notification.
    ///
    /// If the remote notification is for the subscription created with `subscribeToChanges()`
    /// then `fetchChanges()` will be called.
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

}
