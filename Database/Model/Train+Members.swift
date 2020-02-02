//
//  Train+Members.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/2/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Train {
    /// Add a new `TrainMember` to the train.
    ///
    /// The new `TrainMember` is inserted into the same `managedObjectContext` as this train, added to the `members`
    /// set, and the `index` set to the next value in sequence.
    /// - Returns: `TrainMember` now present in `members`.
    public func addMember() -> TrainMember {
        var maxIndex: Int16?
        if let members = members {
            for case let member as TrainMember in members {
                if maxIndex == nil || member.index > maxIndex! {
                    maxIndex = member.index
                }
            }
        }

        let member = TrainMember(entity: TrainMember.entity(), insertInto: managedObjectContext)
        if let maxIndex = maxIndex {
            member.index = maxIndex + 1
        } else {
            member.index = 0
        }

        addToMembers(member)

        return member
    }

    /// Remove a `TrainMember` from the train.
    ///
    /// `member` is removed from the `members` set, deleted from its `managedObjectContext` and all `index` of each
    /// other member in `members` adjusted.
    /// - Parameter member: `TrainMember` to be removed.
    public func removeMember(_ member: TrainMember) {
        removeFromMembers(member)

        if let members = members {
            var followingMembers: [TrainMember] = []
            for case let followingMember as TrainMember in members {
                if followingMember.index >= member.index {
                    followingMembers.append(followingMember)
                }
            }

            followingMembers.sort { $0.index < $1.index }
            for (offset, followingMember) in followingMembers.enumerated() {
                followingMember.index = member.index + Int16(clamping: offset)
            }
        }

        managedObjectContext?.delete(member)
    }

    /// Move a `TrainMember` within the train.
    /// - Parameters:
    ///   - member: `TrainMember` to be moved.
    ///   - otherMember: `TrainMember` that `member` is to be placed before.
    public func moveMember(_ member: TrainMember, before otherMember: TrainMember) {
        guard member != otherMember else { return }

        let indexes = min(member.index, otherMember.index)...max(member.index, otherMember.index)

        if let members = members {
            var reorderMembers: [TrainMember] = []
            var followingMembers: [TrainMember] = []
            for case let reoderMember as TrainMember in members {
                guard reoderMember != member else { continue }
                if indexes.contains(reoderMember.index) {
                    reorderMembers.append(reoderMember)
                } else if reoderMember.index > indexes.upperBound {
                    followingMembers.append(reoderMember)
                }
            }

            reorderMembers.sort { $0.index < $1.index }
            reorderMembers.insert(member, at: reorderMembers.firstIndex(of: otherMember)!)
            if reorderMembers.count > indexes.count {
                print("FIXING: more train members within move than indexes available")
                followingMembers.sort { $0.index < $1.index }
                reorderMembers.append(contentsOf: followingMembers)
            }

            for (offset, reorderMember) in reorderMembers.enumerated() {
                reorderMember.index = indexes.lowerBound + Int16(clamping: offset)
            }
        }
    }
}
