//
//  SimpleTokenFieldDelegate.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import AppKit

@objc
class SimpleTokenFieldDelegate : NSObject, NSTokenFieldDelegate {
    
    var completionBlock: (String?) throws -> [String]
    
    init(using completionBlock: @escaping (String?) throws -> [String]) {
        self.completionBlock = completionBlock
    }
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return try? completionBlock(substring)
    }
    
}

