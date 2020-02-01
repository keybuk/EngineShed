//
//  ConvertibleFromString.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/19/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

/// A type that can be initialized from a textual representation.
///
/// Types that conform to the `ConvertibleFromString` protocol are typically enumerations without
/// associated values but with a common textual description.
///
/// Conformance is automatically provided for any enumeration conforming to both `CaseIterable` and
/// `CustomStringConvertible`.
public protocol ConvertibleFromString {
    init?(describedBy: String)
}

extension ConvertibleFromString
where Self: CaseIterable & CustomStringConvertible {
    public init?(describedBy string: String) {
        if let matchingCase = Self.allCases.first(where: { String(describing: $0) == string }) {
            self = matchingCase
        } else {
            return nil
        }
    }
}
