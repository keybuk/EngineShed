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
public final class PersistentContainer: NSPersistentContainer {
    /// Shared container instance.
    ///
    /// This is used to ensure the running app, and unit tests running within it, share the same
    /// `managedObjectModel`.
    public static let shared: PersistentContainer = {
        return PersistentContainer(name: "EngineShed")
    }()
}
