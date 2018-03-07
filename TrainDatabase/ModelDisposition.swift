//
//  ModelDisposition.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/19/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

enum ModelDisposition : Int16, Codable {
    
    case normal = 1
    case collectorItem
    case spareParts
    
}

extension ModelDisposition : EnumeratableEnum, CustomStringConvertible, ConvertibleFromString {
    
    static let all: [ModelDisposition] = [ .normal, .collectorItem, .spareParts ]

    var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .collectorItem:
            return "Collector Item"
        case .spareParts:
            return "Spare Parts"
        }
    }
    
}

