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
