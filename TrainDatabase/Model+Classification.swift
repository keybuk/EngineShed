//
//  Model+Classification.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {
    enum Classification: Int16, CaseIterable {
        case locomotive = 1
        case coach
        case wagon
        case multipleUnit
        case departmental
        case noPrototype
        case accessory
        case vehicle
    }

    var classification: Classification? {
        get { Classification(rawValue: classificationRawValue) }
        set { classificationRawValue = newValue?.rawValue ?? 0 }
    }
}

extension Model.Classification: CustomStringConvertible, ConvertibleFromString {
    var description: String {
        switch self {
        case .locomotive: return "Locomotive"
        case .coach: return "Coach"
        case .wagon: return "Wagon"
        case .multipleUnit: return "Multiple Unit"
        case .departmental: return "Departmental"
        case .noPrototype: return "No Prototype"
        case .accessory: return "Accessory"
        case .vehicle: return "Vehicle"
        }
    }
}
