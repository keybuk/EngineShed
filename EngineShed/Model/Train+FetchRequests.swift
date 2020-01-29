//
//  Train+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/2/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Train {

    func fetchRequestForMembers() -> NSFetchRequest<TrainMember> {
        let fetchRequest: NSFetchRequest<TrainMember> = TrainMember.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        fetchRequest.predicate = NSPredicate(format: "train = %@", self)

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "index", ascending: true))

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }

}
