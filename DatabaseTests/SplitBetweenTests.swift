//
//  SplitBetweenTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import XCTest

import Database

class SplitBetweenTests: XCTestCase {
    // MARK: splitBetween

    /// Check that the function works as expected on Array.
    func testSplitBetween() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { $0 > $1 })
        XCTAssertEqual(result, [[1, 2, 3], [2, 3, 4, 4], [3, 4, 6], [1, 1]])
    }

    /// Check that the function works as expected when every element needs to be split.
    func testSplitBetweenEverything() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { _, _ in true })
        XCTAssertEqual(result, [[1], [2], [3], [2], [3], [4], [4], [3], [4], [6], [1], [1]])
    }

    /// Check that the function works as expected when only the last element needs to be split.
    func testSplitBetweenSplitAtLast() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { $0 == $1 })
        XCTAssertEqual(result, [[ 1, 2, 3, 2, 3, 4], [4, 3, 4, 6, 1], [1]])
    }

    /// Check that the function works as expected when the predicate is not found.
    func testSplitBetweenNotFound() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { $1 - $0 > 2 })
        XCTAssertEqual(result, [[ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]])
    }

    // MARK: indexOfAdjacent

    /// Check that the function works as expected on Array.
    func testIndexOfAdjacent() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { abs($0 - $1) > 1 }), 8)
    }

    /// Check that the function returns the first of multiple matching pairs.
    func testIndexOfAdjacentReturnsFirst() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { $0 > $1 }), 2)
    }

    /// Check that the function works when the last pair matches,
    func testIndexOfAdjacentWorksForLast() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { $0 == $1 && $0 == 1 }), 10)
    }

    /// Check that the function works as expected when the predicate is not found.
    func testIndexOfAdjacentMissing() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { $1 - $0 > 2 }), nil)
    }
}
