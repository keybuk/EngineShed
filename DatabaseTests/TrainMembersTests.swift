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

        let existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 0
        train.addToMembers(existingTrainMember)

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 1)
    }

    /// Check that if there's a gap in indexes, things still work out.
    func testAddTrainMemberWithGap() {
        let train = Train(context: container!.viewContext)

        var existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 0
        train.addToMembers(existingTrainMember)

        existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 2
        train.addToMembers(existingTrainMember)

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 3)
    }

    /// Check that if there's a duplication in indexes, things still work out.
    func testAddTrainMemberWithDuplicate() {
        let train = Train(context: container!.viewContext)

        var existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 0
        train.addToMembers(existingTrainMember)

        existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 1
        train.addToMembers(existingTrainMember)

        existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 1
        train.addToMembers(existingTrainMember)

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 2)
    }

    // MARK: removeMember

    /// Check that we can remove the only member from a train.
    func testRemoveMember() {
        let train = Train(context: container!.viewContext)

        let member = TrainMember(context: container!.viewContext)
        member.index = 0
        train.addToMembers(member)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
    }

    /// Check that we can remove a second member from a train.
    func testRemoveSecondTrainMember() {
        let train = Train(context: container!.viewContext)

        let existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 0
        train.addToMembers(existingTrainMember)

        let member = TrainMember(context: container!.viewContext)
        member.index = 1
        train.addToMembers(member)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember) ?? false)

        XCTAssertEqual(existingTrainMember.index, 0)
    }

    /// Check that we can remove the first of two members from a train, and the second is reindexed.
    func testRemoveFirstTrainMemberOfTwo() {
        let train = Train(context: container!.viewContext)

        let member = TrainMember(context: container!.viewContext)
        member.index = 0
        train.addToMembers(member)

        let existingTrainMember = TrainMember(context: container!.viewContext)
        existingTrainMember.index = 1
        train.addToMembers(existingTrainMember)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember) ?? false)

        XCTAssertEqual(existingTrainMember.index, 0)
    }

    /// Check that we can remove the first of three members from a train, and the second and third are reindexed.
    func testRemoveFirstTrainMemberOfThree() {
        let train = Train(context: container!.viewContext)

        let member = TrainMember(context: container!.viewContext)
        member.index = 0
        train.addToMembers(member)

        let existingTrainMember1 = TrainMember(context: container!.viewContext)
        existingTrainMember1.index = 1
        train.addToMembers(existingTrainMember1)

        let existingTrainMember2 = TrainMember(context: container!.viewContext)
        existingTrainMember2.index = 2
        train.addToMembers(existingTrainMember2)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember1) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember2) ?? false)

        XCTAssertEqual(existingTrainMember1.index, 0)
        XCTAssertEqual(existingTrainMember2.index, 1)
    }

    /// Check that gaps before a member index aren't affected up by remove.
    func testRemoveMemberAfterGap() {
        let train = Train(context: container!.viewContext)

        let existingTrainMember1 = TrainMember(context: container!.viewContext)
        existingTrainMember1.index = 0
        train.addToMembers(existingTrainMember1)

        let existingTrainMember2 = TrainMember(context: container!.viewContext)
        existingTrainMember2.index = 2
        train.addToMembers(existingTrainMember2)

        let member = TrainMember(context: container!.viewContext)
        member.index = 3
        train.addToMembers(member)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember1) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember2) ?? false)

        XCTAssertEqual(existingTrainMember1.index, 0)
        XCTAssertEqual(existingTrainMember2.index, 2)
    }

    /// Check that gaps after a member index are cleaned up by remove.
    func testRemoveMemberBeforeGap() {
        let train = Train(context: container!.viewContext)

        let member = TrainMember(context: container!.viewContext)
        member.index = 0
        train.addToMembers(member)

        let existingTrainMember1 = TrainMember(context: container!.viewContext)
        existingTrainMember1.index = 1
        train.addToMembers(existingTrainMember1)

        let existingTrainMember2 = TrainMember(context: container!.viewContext)
        existingTrainMember2.index = 3
        train.addToMembers(existingTrainMember2)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember1) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember2) ?? false)

        XCTAssertEqual(existingTrainMember1.index, 0)
        XCTAssertEqual(existingTrainMember2.index, 1)
    }

    /// Check that duplicates before a member index aren't affected up by remove.
    func testRemoveMemberAfterDuplicate() {
        let train = Train(context: container!.viewContext)

        let existingTrainMember1 = TrainMember(context: container!.viewContext)
        existingTrainMember1.index = 0
        train.addToMembers(existingTrainMember1)

        let existingTrainMember2 = TrainMember(context: container!.viewContext)
        existingTrainMember2.index = 0
        train.addToMembers(existingTrainMember2)

        let member = TrainMember(context: container!.viewContext)
        member.index = 1
        train.addToMembers(member)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember1) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember2) ?? false)

        XCTAssertEqual(existingTrainMember1.index, 0)
        XCTAssertEqual(existingTrainMember2.index, 0)
    }

    /// Check that duplicates after a member index are cleaned up by remove.
    func testRemoveMemberBeforeDuplicate() {
        let train = Train(context: container!.viewContext)

        let member = TrainMember(context: container!.viewContext)
        member.index = 0
        train.addToMembers(member)

        let existingTrainMember1 = TrainMember(context: container!.viewContext)
        existingTrainMember1.index = 1
        train.addToMembers(existingTrainMember1)

        let existingTrainMember2 = TrainMember(context: container!.viewContext)
        existingTrainMember2.index = 1
        train.addToMembers(existingTrainMember2)


        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember1) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember2) ?? false)

        // Non-deterministic which way the cleanup works.
        if existingTrainMember1.index == 0 {
            XCTAssertEqual(existingTrainMember1.index, 0)
            XCTAssertEqual(existingTrainMember2.index, 1)
        } else {
            XCTAssertEqual(existingTrainMember2.index, 0)
            XCTAssertEqual(existingTrainMember1.index, 1)
        }
    }

    /// Check that duplicates at a member index are cleaned up by remove.
    func testRemoveMemberFromDuplicate() {
        let train = Train(context: container!.viewContext)

        let member = TrainMember(context: container!.viewContext)
        member.index = 0
        train.addToMembers(member)

        let existingTrainMember1 = TrainMember(context: container!.viewContext)
        existingTrainMember1.index = 0
        train.addToMembers(existingTrainMember1)

        let existingTrainMember2 = TrainMember(context: container!.viewContext)
        existingTrainMember2.index = 1
        train.addToMembers(existingTrainMember2)

        train.removeMember(member)

        XCTAssertTrue(member.isDeleted)
        XCTAssertNil(member.train)
        XCTAssertFalse(train.members?.contains(member) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember1) ?? false)
        XCTAssertTrue(train.members?.contains(existingTrainMember2) ?? false)

        XCTAssertEqual(existingTrainMember1.index, 0)
        XCTAssertEqual(existingTrainMember2.index, 1)
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

        train.moveMember(members[4], before: members[2])

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

        train.moveMember(members[1], before: members[4])

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

        train.moveMember(members[4], before: members[4])

        for (index, member) in members.enumerated() {
            XCTAssertEqual(member.index, Int16(clamping: index))
        }
    }

    /// Check that a gap before the move isn't cleaned up.
    func testMoveTrainMemberGapBefore() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 2, 3, 4, 5, 6] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMember(members[4], before: members[2])

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 2)
        XCTAssertEqual(members[2].index, 4)
        XCTAssertEqual(members[3].index, 5)
        XCTAssertEqual(members[4].index, 3)
        XCTAssertEqual(members[5].index, 6)
    }

    /// Check that a gap after the move isn't cleaned up.
    func testMoveTrainMemberGapAfter() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 2, 3, 4, 6] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMember(members[1], before: members[4])

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 3)
        XCTAssertEqual(members[2].index, 1)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 6)
    }

    /// Check that a duplicate within the move segment is cleaned up, and following members reindexed because they have to be.
    func testMoveTrainMemberDuplicateWithin() {
        let train = Train(context: container!.viewContext)

        var members: [TrainMember] = []
        for index in [0, 1, 2, 2, 3, 4] {
            let member = TrainMember(context: container!.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
        }

        train.moveMember(members[1], before: members[4])

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 3)
        // Non-deterministic which way the cleanup works.
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
}
