//
//  PurchaseCondition.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

enum PurchaseCondition : Int16, Codable {

    case new = 1
    case likeNew
    case used
    case usedInWrongBox
    case handmade
    
}

extension PurchaseCondition : EnumeratableEnum, CustomStringConvertible, ConvertibleFromString {
    
    static let all: [PurchaseCondition] = [ .new, .likeNew, .used, .usedInWrongBox, .handmade ]

    var description: String {
        switch self {
        case .new:
            return "New"
        case .likeNew:
            return "Like New"
        case .used:
            return "Used"
        case .usedInWrongBox:
            return "Used in Wrong Box"
        case .handmade:
            return "Handmade"
        }
    }
    
}
