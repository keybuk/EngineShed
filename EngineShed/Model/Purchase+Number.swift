//
//  Purchase+Number.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/2/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension Purchase {

    /// `catalogYear` formatted as string.
    var catalogYearAsString: String? {
        get {
            if catalogYear == 0 { return nil }
            return String(catalogYear)
        }

        set {
            catalogYear = newValue.flatMap { Int16($0) } ?? 0
        }
    }

    /// `limitedEditionNumber` formatted as string.
    var limitedEditionNumberAsString: String? {
        get {
            if limitedEditionNumber == 0 { return nil }
            return String(limitedEditionNumber)
        }

        set {
            limitedEditionNumber = newValue.flatMap { Int16($0) } ?? 0
        }
    }

    /// `limitedEditionCount` formatted as string.
    var limitedEditionCountAsString: String? {
        get {
            if limitedEditionCount == 0 { return nil }
            return String(limitedEditionCount)
        }

        set {
            limitedEditionCount = newValue.flatMap { Int16($0) } ?? 0
        }
    }

}
