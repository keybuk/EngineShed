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
    /// Update the indexes of the `members`.
    ///
    /// - Parameter changing: closure to make changes to the `members` list, invoked between sorting `members` and
    /// applying new indexes.
    func updateMemberIndexes(changing: ((inout [TrainMember]) -> Void)? = nil) {
        guard let members = members as? Set<TrainMember> else { return }

        var sortedMembers = members.sorted { $0.index < $1.index }
        changing?(&sortedMembers)

        for (newIndex, member) in sortedMembers.enumerated() {
            if member.index != newIndex { member.index = Int16(clamping: newIndex) }
        }
    }

    /// Add a new `TrainMember` to the train.
    ///
    /// The new `TrainMember` is inserted into the same `managedObjectContext` as this train, added to the `members`
    /// set, and the `index` set to the next value in sequence.
    ///
    /// - Returns: `TrainMember` now present in `members`.
    public func addMember() -> TrainMember {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot add a member to a train without a managed object context")
        }

        var member: TrainMember!
        managedObjectContext.performAndWait {
            member = TrainMember(context: managedObjectContext)
            updateMemberIndexes {
                $0.append(member)
            }
            addToMembers(member)
        }
        return member
    }

    /// Remove a `TrainMember` from the train.
    ///
    /// `member` is removed from the `members` set, deleted from its `managedObjectContext` and all `index` of each
    /// other member in `members` adjusted.
    /// 
    /// - Parameter member: `TrainMember` to be removed.
    public func removeMember(_ member: TrainMember) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot remove a member from a train without a managed object context")
        }

        managedObjectContext.performAndWait {
            removeFromMembers(member)
            updateMemberIndexes()
            managedObjectContext.delete(member)
        }
    }

    /// Move a `TrainMember` within the train from one position to another.
    ///
    /// After calling this method, the member at the zero-indexed `origin` position within the set of `members`
    /// will have the new index `destination` with all indexes adjusted
    ///
    /// Note that when moving a member to a lower position, after calling this method, the member will be placed **before**
    /// the member currently at the `destination` index; while when moving a member to a higher position, the member
    /// will be placed **after** the member currently at the `destination`.
    ///
    /// - Parameters:
    ///   - origin: The position of the member that you want to move.
    ///   - destination: The member's new position.
    public func moveMemberAt(_ origin: Int, to destination: Int) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot move a member within a train without a managed object context")
        }

        guard origin != destination else { return }
        managedObjectContext.performAndWait {
            updateMemberIndexes {
                let originIndex = $0.index($0.startIndex, offsetBy: origin)
                let destinationIndex = $0.index($0.startIndex, offsetBy: destination)
                $0.insert($0.remove(at: originIndex), at: destinationIndex)
            }
        }
    }
}
