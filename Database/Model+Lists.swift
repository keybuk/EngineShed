//
//  Model+Lists.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Model {

    /// Update list of relationship objects from a string list.
    ///
    /// Since Core Data has no concept of a string list, and to reduce the model burden on the
    /// Cloud Kit and View sides, we translate between string lists and relationships with sets of
    /// objects that just contain a title.
    ///
    /// - Parameters:
    ///   - objects: set of objects in the relationship.
    ///   - titles: list of titles.
    ///   - as: type of `NSManagedObject` to construct.
    func updateList<Entity: NSManagedObject>(_ objects: NSSet?, from titles: [String]?, as type: Entity.Type) {
        guard let managedObjectContext = managedObjectContext else { preconditionFailure("Can't update list field outside of managed object context") }

        var newTitles = Set(titles ?? [])

        // Remove any database object not in `newTitles`, or any new title that's in the database.
        if let objects = objects as? Set<NSManagedObject> {
            for object in objects {
                guard let title = object.value(forKey: "title") as? String else { continue }
                if newTitles.contains(title) {
                    newTitles.remove(title)
                } else {
                    managedObjectContext.performAndWait {
                        object.setValue(nil, forKey: "model")
                        managedObjectContext.delete(object)
                    }
                }
            }
        }

        // Insert any title left in `newTitles`.
        for title in newTitles {
            let object = Entity(context: managedObjectContext)
            object.setValue(self, forKey: "model")
            object.setValue(title, forKey: "title")
        }
    }

    /// Update the set of `lights` from string list.
    public func updateLights(from titles: [String]?) {
        updateList(lights, from: titles, as: Light.self)
    }

}
