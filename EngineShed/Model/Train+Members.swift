//
//  Train+Members.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/2/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Train {

    func addMember(_ trainMember: TrainMember) {
        addToMembers(trainMember)
    }

    func removeMember(_ trainMember: TrainMember) {
        removeFromMembers(trainMember)
    }

    func moveMember(from fromIndex: Int, to toIndex: Int) {

    }

}
