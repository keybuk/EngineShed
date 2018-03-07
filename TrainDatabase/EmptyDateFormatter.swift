//
//  EmptyDateFormatter.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/29/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

class EmptyDateFormatter : DateFormatter {
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
        if string.isEmpty {
            obj?.pointee = nil
        } else {
            try super.getObjectValue(obj, for: string, range: rangep)
        }
    }
    
}
