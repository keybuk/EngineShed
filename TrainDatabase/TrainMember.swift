//
//  TrainMember.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension TrainMember {
    @discardableResult
    func deleteIfUnused() -> Bool {
        if model == nil && (details?.isEmpty ?? true) {
            train?.removeMember(self)
            return true
        } else {
            return false
        }
    }
}
