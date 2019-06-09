//
//  Model+Classification.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

public enum ModelClassification : Int16, CaseIterable {

    case locomotive = 1
    case coach
    case wagon
    case multipleUnit
    case departmental
    case maintenance
    case accessory
    
}

extension ModelClassification : CustomStringConvertible, ConvertibleFromString {
    
    public var description: String {
        switch self {
        case .locomotive: return "Locomotive"
        case .coach: return "Coach"
        case .wagon: return "Wagon"
        case .multipleUnit: return "Multiple Unit"
        case .departmental: return "Departmental"
        case .maintenance: return "Maintenance"
        case .accessory: return "Accessory"
        }
    }
    
}

extension Model {

    public var classification: ModelClassification? {
        get { return ModelClassification(rawValue: classificationRawValue) }
        set { classificationRawValue = newValue?.rawValue ?? 0 }
    }

}
