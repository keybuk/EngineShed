//
//  SplitBetweenTests.swift
//  EngineShedTests
//
//  Created by Scott James Remnant on 6/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import XCTest

@testable import EngineShed

class SplitBetweenTests : XCTestCase {

    // MARK: splitBetween

    func testSplitBetween() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { $0 > $1 })
        XCTAssertEqual(result, [[1, 2, 3], [2, 3, 4, 4], [3, 4, 6], [1, 1]])
    }

    func testSplitBetweenEverything() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { _, _ in true })
        XCTAssertEqual(result, [[1], [2], [3], [2], [3], [4], [4], [3], [4], [6], [1], [1]])
    }

    func testSplitBetweenSplitAtLast() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { $0 == $1 })
        XCTAssertEqual(result, [[ 1, 2, 3, 2, 3, 4], [4, 3, 4, 6, 1], [1]])
    }

    func testSplitBetweenNotFound() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        let result = integers.split(between: { $1 - $0 > 2 })
        XCTAssertEqual(result, [[ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]])
    }

    // MARK: indexOfAdjacent

    func testIndexOfAdjacent() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { abs($0 - $1) > 1 }), 8)
    }

    func testIndexOfAdjacentReturnsFirst() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { $0 > $1 }), 2)
    }

    func testIndexOfAdjacentWorksForLast() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { $0 == $1 && $0 == 1 }), 10)
    }
    
    func testIndexOfAdjacentMissing() {
        let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 6, 1, 1 ]
        XCTAssertEqual(integers.indexOfAdjacent(where: { $1 - $0 > 2 }), nil)
    }

}
