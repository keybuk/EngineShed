//
//  Train+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/2/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Train {
    /// Returns an `NSFetchRequest` for all members of this train.
    public func fetchRequestForMembers() -> NSFetchRequest<TrainMember> {
        let fetchRequest: NSFetchRequest<TrainMember> = TrainMember.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "train = %@", self)

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "index", ascending: true))
        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}
