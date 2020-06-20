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
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Returns: `TrainMember` now present in `members`.
    public func addMember() -> TrainMember {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot add a member to a train without a managed object context")
        }

        let member = TrainMember(context: managedObjectContext)
        member.index = maxMemberIndex + 1
        maxMemberIndex = member.index
        addToMembers(member)

        return member
    }

    /// Remove a `TrainMember` from the train.
    ///
    /// `member` is removed from the `members` set, deleted from its `managedObjectContext` and all `index` of each
    /// other member in `members` adjusted.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameter member: `TrainMember` to be removed.
    public func removeMember(_ member: TrainMember) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot remove a member from a train without a managed object context")
        }

        guard let members = members as? Set<TrainMember> else { return }

        removeFromMembers(member)

        for other in members {
            if other.index > member.index {
                other.index -= 1
            }
        }

        maxMemberIndex -= 1
        managedObjectContext.delete(member)
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
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameters:
    ///   - origin: The position of the member that you want to move.
    ///   - destination: The member's new position.
    public func moveMemberAt(_ origin: Int, to destination: Int) {
        guard let _ = managedObjectContext else {
            preconditionFailure("Cannot move a member within a train without a managed object context")
        }

        guard origin != destination else { return }
        guard let members = members as? Set<TrainMember> else { return }

        for member in members {
            if (member.index == origin) {
                member.index = Int16(clamping: destination)
            } else if (destination > origin && member.index > origin && member.index <= destination) {
                member.index -= 1
            } else if (destination < origin && member.index >= destination && member.index < origin) {
                member.index += 1
            }
        }
    }
}
