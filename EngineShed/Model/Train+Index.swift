//
//  Train+Index.swift
//  EngineShed
//
//  Created by Scott James Remnant on 9/25/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Train {

    /// Update the index fields of members.
    func updateMemberIndexes() {
        guard let members = members else { return }

        for (index, member) in members.enumerated() {
            let index = Int16(clamping: index)
            let member = member as! TrainMember
            if member.index != index { member.index = index }
        }
    }

}
