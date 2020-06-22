//
//  PersistentContainer.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/28/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import CoreData

/// Subclass `NSPersistentContainer` place to correctly default the bundle for the data model.
///
/// This also turns out to be a useful place to connect the core data persistent store with the
/// CloudKit observer and provider.
public final class PersistentContainer: NSPersistentCloudKitContainer {
    private override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }
}

extension PersistentContainer {
    /// Shared container instance.
    ///
    /// This is used to ensure the running app, and unit tests running within it, share the same
    /// `managedObjectModel`.
    public static let shared: PersistentContainer = {
        ValueTransformer.setValueTransformer(
            SecureUnarchiveDateComponentsFromDataTransformer(),
            forName: NSValueTransformerName(rawValue: "SecureUnarchiveDateComponentsFromDataTransformer"))

        let container = PersistentContainer(name: "EngineShed")
        guard let containerStoreDescription = container.persistentStoreDescriptions.first else {
            preconditionFailure("Missing persistent store description")
        }
        containerStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        return container
    }()

    /// Creates a main-queue managed object context.
    ///
    /// Invoking this method causes the persistent container to create and return a new `NSManagedObjectContext` with
    /// the `concurrencyType` of `.mainQueueConcurrencyType`. This new context will be associated with the
    /// `NSPersistentStoreCoordinator` directly and is set to consume `NSManagedObjectContextDidSave`
    /// broadcasts automatically. The `mergePolicy` is set to `.mergeByPropertyObjectTrump` so that local changes
    /// within the context are kept.
    ///
    /// - Returns: a newly created managed object context.
    public func newEditingContext() -> NSManagedObjectContext {
        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        managedObjectContext.automaticallyMergesChangesFromParent = true
        managedObjectContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return managedObjectContext
    }
}

extension PersistentContainer: ObservableObject {
    public static func loadDefaultStore() -> PersistentContainer {
        let container = PersistentContainer.shared
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // Merge changes from the store into the context automatically, these include both
        // CloudKit sync and saves from writable contexts.
        try? container.viewContext.setQueryGenerationFrom(.current)
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
