//
//  Collection+CountedElements.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/26/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

extension Collection where Element : Hashable {

    /// Returns a dictionary of equal elements mapped to their count within the array.
    func countedElements() -> [Element: Int] {
        return reduce(into: [Element: Int](), { $0[$1, default: 0] += 1 })
    }

    /// Returns the most frequent element in the array.
    func mostFrequent() -> Element? {
        return countedElements().max(by: { $0.value < $1.value })?.key
    }

    /// Returns an array of elements with at least `minimum` repeated values.
    ///
    /// - Parameter minimum: minimum number of element occurrences to be returned.
    /// - Returns: array of elements that were repeated at least `minimum` times.
    func repeatedValues(atLeast minimum: Int) -> [Element] {
        return countedElements().filter({ $0.value >= minimum }).map({ $0.key })
    }

}
