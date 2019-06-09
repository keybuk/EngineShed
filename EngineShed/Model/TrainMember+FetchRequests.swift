//
//  TrainMember+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/23/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension TrainMember {

    public static func fetchRequestForTrains() -> NSFetchRequest<TrainMember> {
        let fetchRequest: NSFetchRequest<TrainMember> = TrainMember.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "train.name", ascending: true),
            NSSortDescriptor(key: "index", ascending: true),
        ]

        return fetchRequest
    }

}
