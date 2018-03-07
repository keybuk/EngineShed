//
//  Search.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/4/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

protocol SearchQuery {
    
    var predicate: NSPredicate { get }
    
}

struct GroupSearchQuery : SearchQuery {
    
    enum Operator {
        
        case and
        case or
        
    }
    
    var op: Operator
    var values: [SearchQuery]
    
    
    var predicate: NSPredicate {
        switch op {
        case .and:
            return NSCompoundPredicate(andPredicateWithSubpredicates: values.map({ $0.predicate }))
        case .or:
            return NSCompoundPredicate(orPredicateWithSubpredicates: values.map({ $0.predicate }))
        }
    }
    
}

struct RelationshipSearchQuery : SearchQuery {
    
    enum Operator {
        
        case isSet
        case isNotSet
    }
    
    var field: SearchField
    var op: Operator
    
    
    var predicate: NSPredicate {
        switch op {
        case .isSet:
            return NSPredicate(format: "\(field.keyPath) != NULL")
        case .isNotSet:
            return NSPredicate(format: "\(field.keyPath) = NULL")
        }
    }
    
}

struct LookupSearchQuery : SearchQuery {
    
    enum Operator {
        
        case includes(value: String)
        case doesNotInclude(value: String)
        
        case isEmpty
        case isNotEmpty
    }
    
    var field: SearchField
    var op: Operator
    
    
    var predicate: NSPredicate {
        switch op {
        case .includes(let value):
            return NSPredicate(format: "ANY \(field.keyPath) =[c] %@", value)
        case .doesNotInclude(let value):
            return NSPredicate(format: "SUBQUERY(\(field.keyPath), $field, $field.title =[c] %@).@count = 0", value)
        case .isEmpty:
            return NSPredicate(format: "\(field.keyPath).@count = 0")
        case .isNotEmpty:
            return NSPredicate(format: "\(field.keyPath).@count > 0")
        }
    }

}

