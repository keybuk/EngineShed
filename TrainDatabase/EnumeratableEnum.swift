//
//  EnumeratableEnum.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/19/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

protocol EnumeratableEnum {
    
    static var all: [Self] { get }
    
}

protocol ConvertibleFromString {
    
    init?(describedBy: String)
    
}

extension ConvertibleFromString where Self : EnumeratableEnum & CustomStringConvertible {
    
    init?(describedBy string: String) {
        for enumCase in Self.all {
            if string == enumCase.description {
                self = enumCase
                return
            }
        }
        
        return nil
    }
    
}

