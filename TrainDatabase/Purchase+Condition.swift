//
//  Purchase+Condition.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {
    enum Condition: Int16, CaseIterable {
        case new = 1
        case likeNew
        case used
        case usedInWrongBox
        case handmade
    }

    var condition: Condition? {
        get { Condition(rawValue: managedObject.conditionRawValue) }
        set {
            managedObject.conditionRawValue = newValue?.rawValue ?? 0
            try? managedObject.managedObjectContext?.save() // FIXME!
        }
    }
}

extension Purchase.Condition: CustomStringConvertible, ConvertibleFromString {
    var description: String {
        switch self {
        case .new: return "New"
        case .likeNew: return "Like New"
        case .used: return "Used"
        case .usedInWrongBox: return "Used in Wrong Box"
        case .handmade: return "Handmade"
        }
    }
}
