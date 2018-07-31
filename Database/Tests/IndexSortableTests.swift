//
//  IndexSortableTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/26/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import XCTest

import Database

final class Test : IndexSortable, Equatable, CustomStringConvertible {

    var index: Int

    init(_ index: Int) {
        self.index = index
    }

    static func == (lhs: Test, rhs: Test) -> Bool {
        return lhs.index == rhs.index
    }

    var description: String {
        return "Test(\(index))"
    }

}

class IndexSortableTests : XCTestCase {

    /// New index in an empty array should be a fixed value.
    func testAppendingEmpty() {
        let values: [Test] = []

        let index = values.indexForAppending()
        XCTAssertEqual(index, 64)
    }

    /// New index in an array with items should be the fixed value past the last one.
    func testAppendingNonEmpty() {
        let values: [Test] = [Test(33), Test(92)]

        let index = values.indexForAppending()
        XCTAssertEqual(index, 156)
    }

    /// Inserting at the end of an empty array should be the same as appending.
    func testInsertingEndOfEmpty() {
        let values: [Test] = []

        let index = values.indexForInserting(at: 0)
        XCTAssertEqual(index, 64)
    }

    /// Inserting at the end of a non-empty array should be the same as appending.
    func testInsertingEndOfNonEmpty() {
        let values: [Test] = [Test(33), Test(92)]

        let index = values.indexForInserting(at: 2)
        XCTAssertEqual(index, 156)
    }

    /// Inserting between two items should split the difference in their index.
    func testInsertingBetween() {
        let values: [Test] = [Test(64), Test(128)]

        let index = values.indexForInserting(at: 1)
        XCTAssertEqual(index, 96)
    }

    /// Inserting between two items should work when the difference is odd.
    func testInsertingBetweenOdd() {
        let values: [Test] = [Test(64), Test(127)]

        let index = values.indexForInserting(at: 1)
        XCTAssertEqual(index, 96)
    }

    /// Inserting between two items with only space for one should still work.
    func testInsertingBetweenSpaceOfOne() {
        let values: [Test] = [Test(64), Test(66)]

        let index = values.indexForInserting(at: 1)
        XCTAssertEqual(index, 65)
    }

    /// Inserting between two items with no space should renumber the array.
    func testInsertingBetweenNoSpace() {
        let values: [Test] = [Test(64), Test(65)]

        let index = values.indexForInserting(at: 1)
        XCTAssertEqual(index, 128)

        XCTAssertEqual(values, [Test(64), Test(192)])
    }

    /// Sorting a list of unsorted IndexSortable elements should return a sorted array.
    func testSorted() {
        let unsortedValues: [Test] = [Test(128), Test(33), Test(95)]
        let values = unsortedValues.sorted()

        XCTAssertEqual(values, [Test(33), Test(95), Test(128)])
    }

}
