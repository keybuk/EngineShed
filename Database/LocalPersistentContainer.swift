//
//  LocalPersistentContainer.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/15/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CoreData

/// Subclass `NSPersistentContainer` place to correctly default the bundle for the data model.
public class LocalPersistentContainer : NSPersistentContainer {

    /// Shared container instance.
    ///
    /// This is used to ensure the running app, and unit tests running within it, share the same
    /// `managedObjectModel`.
    public static let shared: LocalPersistentContainer = {
        return LocalPersistentContainer(name: "EngineShed")
    }()

//    override public class func defaultDirectoryURL() -> URL {
//        return super.defaultDirectoryURL().appendingPathComponent("EngineShed")
//    }

}
