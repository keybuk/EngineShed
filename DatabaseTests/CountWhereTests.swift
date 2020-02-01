//
//  CountWhereTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/31/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import XCTest

import Database

class CountWhereTests: XCTestCase {
    /// Check that the function works as expected on Array.
    func testFunction() {
        let names = ["brian", "craig", "robert", "shane", "thomas"]
        let numberOfLongNames = names.count(where: { $0.count > 5 })
        XCTAssertEqual(numberOfLongNames, 2)
    }

    /// Check that we can call the function with a trailing closure syntax.
    func testTrailingClosure() {
        let names = ["brian", "craig", "robert", "shane", "thomas"]
        let numberOfLongNames = names.count {
            $0.count > 5
        }
        XCTAssertEqual(numberOfLongNames, 2)
    }

    /// Check that the function doesn't hide the existing `count` property.
    func testAlongsideProperty() {
        let names = ["brian", "craig", "robert", "shane", "thomas"]
        let numberONames = names.count
        let numberOfLongNames = names.count(where: { $0.count > 5 })
        XCTAssertEqual(numberONames, 5)
        XCTAssertEqual(numberOfLongNames, 2)
    }

    enum NameError: Error {
        case cannotMovePast
    }

    /// Check that we can throw an error from the closure and catch it.
    func testThrowingClosure() {
        let names = ["brian", "craig", "robert", "shane", "thomas"]
        XCTAssertThrowsError(try names.count(where: {
            guard $0 != "shane" else { throw NameError.cannotMovePast }
            return $0.count > 5
        }))
    }

    /// Check that the function works on an empty Array.
    func testEmptyArray() {
        let names: [String] = []
        let numberOfLongNames = names.count(where: { $0.count > 5 })
        XCTAssertEqual(numberOfLongNames, 0)
    }

    /// Check that the function works on a Sequence.
    func testOnSequence() {
        let names = ["brian", "craig", "robert", "shane", "thomas"]
        let numberOfLongNames = names.lazy.count(where: { $0.count > 5 })
        XCTAssertEqual(numberOfLongNames, 2)
    }
}
