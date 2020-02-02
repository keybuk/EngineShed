//
//  Train.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Train {
    @discardableResult
    func deleteIfUnused() -> Bool {
        if let count = members?.count, count > 0 {
            managedObjectContext?.delete(self)
            return true
        } else {
            return false
        }
    }
}
