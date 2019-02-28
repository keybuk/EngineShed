//
//  LocalPersistentContainer.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/15/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

/// Subclass `NSPersistentContainer` place to correctly default the bundle for the data model.
///
/// This also turns out to be a useful place to connect the core data persistent store with the
/// CloudKit observer and provider.
public class LocalPersistentContainer : NSPersistentContainer {

    /// Container identifier for CloudKit store.
    let cloudContainerID = "iCloud.com.netsplit.EngineShed"
    
    /// Subscription identifier registered for notifications.
    let subscriptionID = "private-changes"

    public private(set) var cloudContainer: CKContainer
    public private(set) var cloudDatabase: CKDatabase
    
    public private(set) var cloudObserver: CloudObserver!
    public private(set) var cloudProvider: CloudProvider!

    /// Managed object types that we store in CloudKit.
    let storableTypes: [(NSManagedObject & CloudStorable).Type] = [
        Purchase.self,
        Model.self,
        DecoderType.self,
        Decoder.self,
        Train.self,
        TrainMember.self
    ]

    /// Shared container instance.
    ///
    /// This is used to ensure the running app, and unit tests running within it, share the same
    /// `managedObjectModel`.
    public static let shared: LocalPersistentContainer = {
        return LocalPersistentContainer(name: "EngineShed")
    }()

    public override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        cloudContainer = CKContainer(identifier: cloudContainerID)
        cloudDatabase = cloudContainer.privateCloudDatabase

        super.init(name: name, managedObjectModel: model)

        cloudObserver = CloudObserver(database: cloudDatabase, persistentContainer: self, storableTypes: storableTypes)
        cloudProvider = CloudProvider(container: cloudContainer, database: cloudDatabase, persistentContainer: self, storableTypes: storableTypes)
    }
    
//    override public class func defaultDirectoryURL() -> URL {
//        return super.defaultDirectoryURL().appendingPathComponent("EngineShed")
//    }

}
