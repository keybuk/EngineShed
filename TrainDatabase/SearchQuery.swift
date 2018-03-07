//
//  SearchQuery.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

// 


struct FieldSearchQuery<Value> : SearchQuery, Codable
where Value : Codable {
    
    enum Operator {
        
        case contains(value: Value)
        case doesNotContain(value: Value)
        
        case isEqual(value: Value)
        case isNotEqual(value: Value)
        
        case isEmpty
        case isNotEmpty
        
    }
    
    var field: SearchField
    var op: Operator
    
    var predicate: NSPredicate {
        fatalError("Not implemented")
    }
    
    private enum CodingKeys : String, CodingKey {
        case field
        case contains
        case doesNotContain
        case isEqual
        case isNotEqual
        case isEmpty
        case isNotEmpty
    }
    
    init(from decoder: Swift.Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        field = try container.decode(SearchField.self, forKey: .field)
        
        if let value = try container.decodeIfPresent(Value.self, forKey: .contains) {
            op = .contains(value: value)
        } else if let value = try container.decodeIfPresent(Value.self, forKey: .doesNotContain) {
            op = .doesNotContain(value: value)
        } else if let value = try container.decodeIfPresent(Value.self, forKey: .isEqual) {
            op = .isEqual(value: value)
        } else if let value = try container.decodeIfPresent(Value.self, forKey: .isNotEqual) {
            op = .isNotEqual(value: value)
        } else if let _ = try container.decodeIfPresent(Bool.self, forKey: .isEmpty) {
            op = .isEmpty
        } else if let _ = try container.decodeIfPresent(Bool.self, forKey: .isNotEmpty) {
            op = .isNotEmpty
        } else {
            throw DecodingError.dataCorruptedError(forKey: .contains, in: container, debugDescription: "Does not contain a valid operator.")
        }

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(field, forKey: .field)
        
        switch op {
        case .contains(let value):
            try container.encode(value, forKey: .contains)
        case .doesNotContain(let value):
            try container.encode(value, forKey: .doesNotContain)
        case .isEqual(let value):
            try container.encode(value, forKey: .isEqual)
        case .isNotEqual(let value):
            try container.encode(value, forKey: .isNotEqual)
        case .isEmpty:
            try container.encode(true, forKey: .isEmpty)
        case .isNotEmpty:
            try container.encode(true, forKey: .isNotEmpty)
        }
    }
    
}

extension FieldSearchQuery where Value == String {
    
    var predicate: NSPredicate {
        switch op {
        case .contains(let value):
            return NSPredicate(format: "\(field.keyPath) CONTAINS[c] %@", value)
        case .doesNotContain(let value):
            return NSPredicate(format: "NOT \(field.keyPath) CONTAINS[c] %@", value)
        case .isEqual(let value):
            return NSPredicate(format: "\(field.keyPath) =[c] %@", value)
        case .isNotEqual(let value):
            return NSPredicate(format: "\(field.keyPath) !=[c] %@", value)
        case .isEmpty:
            return NSPredicate(format: "(\(field.keyPath) = '' OR \(field.keyPath) = NULL)")
        case .isNotEmpty:
            return NSPredicate(format: "(\(field.keyPath) != '' AND \(field.keyPath) != NULL)")
        }
    }
    
}

extension FieldSearchQuery where Value == Int {
    
    var predicate: NSPredicate {
        switch op {
        case .isEqual(let value):
            return NSPredicate(format: "\(field.keyPath) = %@", value)
        case .isNotEqual(let value):
            return NSPredicate(format: "\(field.keyPath) != %@", value)
        case .isEmpty:
            return NSPredicate(format: "(\(field.keyPath) = 0 OR \(field.keyPath) = NULL)")
        case .isNotEmpty:
            return NSPredicate(format: "(\(field.keyPath) != 0 AND \(field.keyPath) != NULL)")
        default:
            fatalError("Operator not supported for integer fields")
        }
    }
    
}

/*extension FieldSearchQuery where Value == Decimal {
    
    var predicate: NSPredicate {
        switch op {
        case .isEqual(let value):
            return NSPredicate(format: "\(field.keyPath) = %@", value)
        case .isNotEqual(let value):
            return NSPredicate(format: "\(field.keyPath) != %@", value)
        case .isEmpty:
            return NSPredicate(format: "\(field.keyPath) = NULL")
        case .isNotEmpty:
            return NSPredicate(format: "\(field.keyPath) != NULL")
        default:
            fatalError("Operator not supported for decimal fields")
        }
    }
    
}*/

/*extension FieldSearchQuery where Value == Date {
    
    var predicate: NSPredicate {
        switch op {
        case .isEqual(let value):
            return NSPredicate(format: "\(field.keyPath) = %@", value)
        case .isNotEqual(let value):
            return NSPredicate(format: "\(field.keyPath) != %@", value)
        case .isEmpty:
            return NSPredicate(format: "\(field.keyPath) = NULL")
        case .isNotEmpty:
            return NSPredicate(format: "\(field.keyPath) != NULL")
        default:
            fatalError("Operator not supported for date fields")
        }
    }
    
}*/

extension FieldSearchQuery where Value == Bool {
 
    var predicate: NSPredicate {
        switch op {
        case .isEqual(value: true):
            return NSPredicate(format: "\(field.keyPath) = TRUE")
        case .isEqual(value: false):
            return NSPredicate(format: "\(field.keyPath) != TRUE")
        default:
            fatalError("Operator not supported for boolean fields")
        }
    }

}

extension FieldSearchQuery where Value: RawRepresentable, Value.RawValue == Int16 {

    var predicate: NSPredicate {
        switch op {
        case .isEqual(let value):
            return NSPredicate(format: "\(field.keyPath) = %@", value.rawValue)
        case .isNotEqual(let value):
            return NSPredicate(format: "\(field.keyPath) != %@", value.rawValue)
        case .isEmpty:
            return NSPredicate(format: "(\(field.keyPath) = 0 OR \(field.keyPath) = NULL)")
        case .isNotEmpty:
            return NSPredicate(format: "(\(field.keyPath) != 0 AND \(field.keyPath) != NULL)")
        default:
            fatalError("Operator not supported for enumeration fields")
        }
    }

}

