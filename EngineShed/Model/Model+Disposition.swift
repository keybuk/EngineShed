//
//  Model+Disposition.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/19/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

public enum ModelDisposition : Int16, CaseIterable {
    
    case normal = 1
    case collectorItem
    case spareParts
    
}

extension ModelDisposition : CustomStringConvertible, ConvertibleFromString {
    
    public var description: String {
        switch self {
        case .normal: return "Normal"
        case .collectorItem: return "Collector Item"
        case .spareParts: return "Spare Parts"
        }
    }
    
}

extension Model {

    public var disposition: ModelDisposition? {
        get { return ModelDisposition(rawValue: dispositionRawValue) }
        set { dispositionRawValue = newValue?.rawValue ?? 0 }
    }

}
