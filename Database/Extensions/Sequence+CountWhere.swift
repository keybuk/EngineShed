//
//  Sequence+CountWhere.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/31/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

// TODO: Remove once SE-0220 is implemented.

extension Sequence {
    /// Returns the number of elements of the sequence that satisfy the given
    /// predicate.
    ///
    /// In this example, `count(where:)` is used to count only names shorter than
    /// five characters.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let numberOfShortNames = cast.count { $0.count < 5 }
    ///     print(numberOfShortNames)
    ///     // Prints "2"
    ///
    /// - Parameter where: A closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element should be included in the count.
    /// - Returns: The number of elements that `where` allowed.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    public func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self {
            if try predicate(element) {
                count += 1
            }
        }
        return count
    }
}
