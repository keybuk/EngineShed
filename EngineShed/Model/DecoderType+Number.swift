//
//  DecoderType+Number.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension DecoderType {

    /// `minimumStock` formatted as string.
    var minimumStockAsString: String? {
        get {
            if minimumStock == 0 { return nil }
            return String(minimumStock)
        }

        set {
            minimumStock = newValue.flatMap { Int16($0) } ?? 0
        }
    }

}
