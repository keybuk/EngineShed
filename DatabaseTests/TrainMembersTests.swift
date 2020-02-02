//
//  TrainMembersTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/2/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

import Database

class TrainMembersTests: XCTestCase {
    var container: NSPersistentContainer?

    override func setUp() {
        super.setUp()

        container = NSPersistentContainer(name: "EngineShed", managedObjectModel: PersistentContainer.shared.managedObjectModel)
        container?.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container?.loadPersistentStores { (storeDescription, error) in
            XCTAssertNil(error)
        }
    }

    override func tearDown() {
        container = nil

        super.tearDown()
    }

    // MARK: addMember

    /// Check that we can add a member to an empty train.
    func testAddFirstTrainMember() {
        let train = Train(context: container!.viewContext)
        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 0)
    }

    /// Check that we can add a second member to a train.
    func testAddSecondTrainMember() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 1)

        XCTAssertEqual(members[0].index, 0)
    }

    /// Check that if there's a gap in indexes, we can still add a new one, and the existing ones get fixed.
    func testAddTrainMemberWithGap() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 2] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 2)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
    }

    /// Check that if there's a duplication in indexes, they're cleaned up, and a new member added afterwards.
    func testAddTrainMemberWithDuplicate() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 3)

        XCTAssertEqual(members[0].index, 0)
        // Cleanup of duplicate indexes is non-deterministic.
        if members[1].index == 1 {
            XCTAssertEqual(members[1].index, 1)
            XCTAssertEqual(members[2].index, 2)
        } else {
            XCTAssertEqual(members[2].index, 1)
            XCTAssertEqual(members[1].index, 2)
        }
    }

    /// Check that adding a mmember makes minimal changes to indexes.
    func testAddMinimizesChanges() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        try! container!.viewContext.save()

        let _ = train.addMember()

        XCTAssertFalse(members[0].hasChanges)
    }

    // MARK: removeMember

    /// Check that we can remove the only member from a train.
    func testRemoveMember() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
    }

    /// Check that we can remove a second member from a train.
    func testRemoveSecondTrainMember() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[1])

        XCTAssertTrue(members[1].isDeleted)
        XCTAssertNil(members[1].train)
        XCTAssertFalse(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[0]) ?? false)

        XCTAssertEqual(members[0].index, 0)
    }

    /// Check that we can remove the first of two members from a train, and the second is reindexed.
    func testRemoveFirstTrainMemberOfTwo() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)

        XCTAssertEqual(members[1].index, 0)
    }

    /// Check that we can remove the first of three members from a train, and the second and third are reindexed.
    func testRemoveFirstTrainMemberOfThree() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 2] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[2]) ?? false)

        XCTAssertEqual(members[1].index, 0)
        XCTAssertEqual(members[2].index, 1)
    }

    /// Check that gaps before a member index are cleaned up after a remove.
    func testRemoveMemberAfterGap() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 2, 3] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[2])

        XCTAssertTrue(members[2].isDeleted)
        XCTAssertNil(members[2].train)
        XCTAssertFalse(train.members?.contains(members[2]) ?? false)
        XCTAssertTrue(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
    }

    /// Check that gaps after a member index are cleaned up by remove.
    func testRemoveMemberBeforeGap() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 3] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[2]) ?? false)

        XCTAssertEqual(members[1].index, 0)
        XCTAssertEqual(members[2].index, 1)
    }

    /// Check that duplicates before a member index are cleaned up by a remove.
    func testRemoveMemberAfterDuplicate() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 0, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[2])

        XCTAssertTrue(members[2].isDeleted)
        XCTAssertNil(members[2].train)
        XCTAssertFalse(train.members?.contains(members[2]) ?? false)
        XCTAssertTrue(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)

        // Cleanup of duplicate indexes is non-deterministic.
        if members[0].index == 0 {
            XCTAssertEqual(members[0].index, 0)
            XCTAssertEqual(members[1].index, 1)
        } else {
            XCTAssertEqual(members[1].index, 0)
            XCTAssertEqual(members[0].index, 1)
        }
    }

    /// Check that duplicates after a member index are cleaned up by remove.
    func testRemoveMemberBeforeDuplicate() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[2]) ?? false)

        // Cleanup of duplicate indexes is non-deterministic.
        if members[1].index == 0 {
            XCTAssertEqual(members[1].index, 0)
            XCTAssertEqual(members[2].index, 1)
        } else {
            XCTAssertEqual(members[2].index, 0)
            XCTAssertEqual(members[1].index, 1)
        }
    }

    /// Check that duplicates at a member index are cleaned up by remove.
    func testRemoveMemberFromDuplicate() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 0, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[2]) ?? false)

        XCTAssertEqual(members[1].index, 0)
        XCTAssertEqual(members[2].index, 1)
    }

    /// Check that removing a member makes minimal changes to indexes.
    func testRemoveMinimizesChanges() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        try! container!.viewContext.save()

        train.removeMember(members[1])

        XCTAssertFalse(members[0].hasChanges)
    }

    // MARK: moveMember

    /// Check that moving a member forwards works.
    func testMoveTrainMemberForwards() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(4, to: 2)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 4)
        XCTAssertEqual(members[4].index, 2)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that moving a member backwards works.
    func testMoveTrainMemberBackwards() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(1, to: 3)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 3)
        XCTAssertEqual(members[2].index, 1)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that moving a member to its existing location does nothing.
    func testMoveTrainMemberToSameTrainMember() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(4, to: 4)

        for (index, member) in members.enumerated() {
            XCTAssertEqual(member.index, Int16(clamping: index))
        }
    }

    /// Check that swapping two members forward in the middle of the set works.
    func testMoveTrainMemberSwapForwards() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(2, to: 3)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that swapping two members backward in the middle of the set works.
    func testMoveTrainMemberSwapBackwards() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(3, to: 2)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that we can swap two members forwards.
    func testMoveTrainMemberSwapTwoForwards() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(1, to: 0)

        XCTAssertEqual(members[0].index, 1)
        XCTAssertEqual(members[1].index, 0)
    }

    /// Check that we can swap two members backwards.
    func testMoveTrainMemberSwapTwoBackwards() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(0, to: 1)

        XCTAssertEqual(members[0].index, 1)
        XCTAssertEqual(members[1].index, 0)
    }

    /// Check that a gap before the move is cleaned up.
    func testMoveTrainMemberGapBefore() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 2, 3, 4, 5, 6] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(4, to: 2)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 4)
        XCTAssertEqual(members[4].index, 2)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that a gap after the move is cleaned up.
    func testMoveTrainMemberGapAfter() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 2, 3, 4, 6] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(1, to: 3)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 3)
        XCTAssertEqual(members[2].index, 1)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that a duplicate within the move segment is cleaned up, and members reindexed.
    func testMoveTrainMemberDuplicateWithin() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 2, 2, 3, 4] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMemberAt(1, to: 3)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 3)
        // Cleanup of duplicate indexes is non-deterministic.
        if members[2].index == 1 {
            XCTAssertEqual(members[2].index, 1)
            XCTAssertEqual(members[3].index, 2)
        } else {
            XCTAssertEqual(members[3].index, 1)
            XCTAssertEqual(members[2].index, 2)
        }
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that moving a member makes minimal changes to indexes.
    func testMoveMinimizesChanges() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        try! container!.viewContext.save()

        train.moveMemberAt(1, to: 3)

        XCTAssertFalse(members[0].hasChanges)
        XCTAssertFalse(members[4].hasChanges)
    }
}
