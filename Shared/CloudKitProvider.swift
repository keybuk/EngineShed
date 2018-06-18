//
//  CloudKitProvider.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

public final class CloudKitProvider {

    public let containerID = "iCloud.com.netsplit.EngineShed"
    public let subscriptionID = "private-changes"
    public let zoneID = CKRecordZone.ID(zoneName: "EngineShed")

    public var container: CKContainer
    public var database: CKDatabase

    public var hasSubscription: Bool = false
    public var serverChangeToken: CKServerChangeToken?
    public var zoneServerChangeToken: [CKRecordZone.ID: CKServerChangeToken?] = [:]

    public init() {
        container = CKContainer(identifier: containerID)
        database = container.privateCloudDatabase
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
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: serverChangeToken)
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

            // TODO: delete the images from Models in this zone
            // TODO: delete all records in this zone

            if let index = self.zoneServerChangeToken.index(forKey: zoneID) {
                self.zoneServerChangeToken.remove(at: index)
            }

        }
        operation.changeTokenUpdatedBlock = { serverChangeToken in
            print("New change token \(serverChangeToken)")

            // TODO: Flush zone deletions for this database to disk
            // TODO: Save the server change token

            self.serverChangeToken = serverChangeToken
        }

        operation.fetchDatabaseChangesCompletionBlock = { serverChangeToken, _, error in
            if let error = error {
                print("Fetch changes error \(error)")
                completionHandler(error)
            } else {
                print("Fetch changes completed \(serverChangeToken!)")

                // TODO: Flush zone deletions for this database to disk
                // TODO: Save the server change token

                self.serverChangeToken = serverChangeToken

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
    public func fetchZoneChanges(_ changedZoneIDs: Set<CKRecordZone.ID>, completionHandler: @escaping (_ error: Error?) -> Void) {
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

            operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: Array(changedZoneIDs), configurationsByRecordZoneID: configurations)
        } else {
            let options = zoneServerChangeToken.mapValues { (serverChangeToken: CKServerChangeToken?) -> CKFetchRecordZoneChangesOperation.ZoneOptions in
                let zoneOptions = CKFetchRecordZoneChangesOperation.ZoneOptions()
                zoneOptions.previousServerChangeToken = serverChangeToken
                return zoneOptions
            }

            operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: Array(changedZoneIDs), optionsByRecordZoneID: options)
        }
        operation.fetchAllChanges = true

        operation.recordChangedBlock = { record in
            print("Record changed \(record)")
            print(record.changedKeys())

            // TODO: create or update the record
        }

        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            print("Record deleted \(recordID) - \(recordType)")

            // TODO: delete the image if this is a Model
            // TODO: delete the record
        }

        operation.recordZoneChangeTokensUpdatedBlock = { zoneID, serverChangeToken, _ in
            print("New zone change token \(zoneID) \(serverChangeToken!)")

            // TODO: Flush record changes and deletions for this zone to disk
            // TODO: Save the zone change token

            self.zoneServerChangeToken[zoneID] = serverChangeToken
        }

        operation.recordZoneFetchCompletionBlock = { zoneID, serverChangeToken, _, _, error in
            if let error = error {
                print("Zone fetch error \(error)")
            } else {
                print("Zone fetch completed \(zoneID) \(serverChangeToken!)")

                // TODO: Flush record changes and deletions for this zone to disk
                // TODO: Save the zone change token

                self.zoneServerChangeToken[zoneID] = serverChangeToken
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

}
