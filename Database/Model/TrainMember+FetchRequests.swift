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
    /// Returns an `NSFetchRequest` for all train members, grouped by train.
    public static func fetchRequestForTrains() -> NSFetchRequest<TrainMember> {
        let fetchRequest: NSFetchRequest<TrainMember> = TrainMember.fetchRequest()

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(contentsOf: [
            NSSortDescriptor(key: "train.name", ascending: true),
            NSSortDescriptor(key: "train", ascending: true),
            NSSortDescriptor(key: "index", ascending: true),
        ])
        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}
