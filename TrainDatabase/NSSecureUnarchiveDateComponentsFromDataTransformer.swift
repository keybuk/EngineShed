//
//  NSSecureUnarchiveDateComponentsFromDataTransformer.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/27/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

@available(OSX 10.14, *)
final class NSSecureUnarchiveDateComponentsFromDataTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] { [NSDateComponents.self] }
    override class func allowsReverseTransformation() -> Bool { true }
}
