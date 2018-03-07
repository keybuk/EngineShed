//
//  SimpleComboBoxDataSource.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import AppKit

@objc
class SimpleComboBoxDataSource : NSObject, NSComboBoxDataSource {
    
    var values: [String]
    
    init(using: (String?) throws -> [String]) throws {
        values = try using(nil)
        super.init()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return values.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return values[index]
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return values.index(of: string) ?? NSNotFound
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        return values.first(where: { $0.lowercased().starts(with: string.lowercased()) })
    }
    
}
