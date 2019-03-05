//
//  DecoderType+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import CoreData

extension DecoderType {

    public static func fetchRequestForDecoderTypes() -> NSFetchRequest<DecoderType> {
        let fetchRequest: NSFetchRequest<DecoderType> = DecoderType.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "minimumStock", ascending: false))
        sortDescriptors.append(NSSortDescriptor(key: "manufacturer", ascending: true))
        sortDescriptors.append(NSSortDescriptor(key: "productCode", ascending: true))
        sortDescriptors.append(NSSortDescriptor(key: "socket", ascending: true))

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }

}

