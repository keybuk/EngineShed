//
//  Train.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Train {
    @discardableResult
    func deleteIfUnused() -> Bool {
        if let count = members?.count, count > 0 {
            managedObjectContext?.delete(self)
            return true
        } else {
            return false
        }
    }

    static func fetchRequestForTrains() -> NSFetchRequest<Train> {
        let fetchRequest: NSFetchRequest<Train> = Train.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return fetchRequest
    }

    func fetchRequestForMembers() -> NSFetchRequest<TrainMember> {
        let fetchRequest: NSFetchRequest<TrainMember> = TrainMember.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "train = %@", self)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "train", ascending: true)
        ]

        return fetchRequest
    }
}
