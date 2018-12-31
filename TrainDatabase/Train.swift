//
//  Train.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

struct Train : ManagedObjectBacked {
    
    var managedObject: TrainManagedObject
    
    init(managedObject: TrainManagedObject) {
        self.managedObject = managedObject
    }
    
    init(context: NSManagedObjectContext) {
        managedObject = TrainManagedObject(context: context)
        managedObject.name = ""
        managedObject.notes = ""
    }

    
    var members: [TrainMember] {
        get {
            let memberObjects = managedObject.members!.array as! [TrainMemberManagedObject]
            return memberObjects.map(TrainMember.init(managedObject:))
        }
        
        set {
            let memberObjects = newValue.map({ $0.managedObject })
            managedObject.members = NSOrderedSet(array: memberObjects)
            try? managedObject.managedObjectContext?.save()
        }
    }
    

    var name: String {
        get { return managedObject.name ?? "" }
        set {
            managedObject.name = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }

    var details: String {
        get { return managedObject.details ?? "" }
        set {
            managedObject.details = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }

    var notes: String {
        get { return managedObject.notes ?? "" }
        set {
            managedObject.notes = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    
    @discardableResult
    func deleteIfUnused() -> Bool {
        if members.isEmpty {
            managedObject.managedObjectContext?.delete(managedObject)
            try? managedObject.managedObjectContext?.save()
            return true
        } else {
            return false
        }
    }
    
    
    static func all(in context: NSManagedObjectContext) throws -> [Train] {
        let fetchRequest: NSFetchRequest<TrainManagedObject> = TrainManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let trainObjects = try context.fetch(fetchRequest)
        return trainObjects.map(Train.init(managedObject:))
    }

}

extension Train : Encodable {
    
    enum CodingKeys : String, CodingKey {
        case name
        case details
        case notes
        case members
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(details, forKey: .details)
        try container.encode(notes, forKey: .notes)
        try container.encode(members, forKey: .members)
    }
    
}

