//
//  ConvertibleFromStringTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/31/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import XCTest

import Database

class ConvertibleFromStringTests: XCTestCase {
    enum Test: CaseIterable, CustomStringConvertible, ConvertibleFromString {
        case one
        case two
        case deux
        case three

        var description: String {
            switch self {
            case .one: return "one"
            case .two: return "two"
            case .deux: return "two"
            case .three: return "three"
            }
        }
    }

    /// Check that we can initialize our test enumeration from a string.
    func testString() {
        let test = Test(describedBy: "one")
        XCTAssertEqual(test, .one)
    }

    /// Check that duplicate descriptions returns the first one.
    func testDuplicateDescription() {
        let test = Test(describedBy: "two")
        XCTAssertEqual(test, .two)
    }

    /// Check that a non-match returns `nil`.
    func testNonMatch() {
        let test = Test(describedBy: "four")
        XCTAssertNil(test)
    }
}
