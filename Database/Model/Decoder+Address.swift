//
//  Decoder+Address.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Decoder {
    /// `address` formatted as string.
    public var addressAsString: String? {
        get {
            if address == 0 { return nil }
            return String(address)
        }
        set { address = newValue.flatMap { Int16($0) } ?? 0 }
    }
}
