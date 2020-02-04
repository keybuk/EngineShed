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

        return PersistentContainer(name: "EngineShed")
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
