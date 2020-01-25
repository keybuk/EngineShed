//
//  ConvertibleFromString.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/19/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

protocol ConvertibleFromString {
    init?(describedBy: String)
}

extension ConvertibleFromString
where Self: CaseIterable & CustomStringConvertible {
    init?(describedBy string: String) {
        if let enumCase = Self.allCases.first(where: { $0.description == string }) {
            self = enumCase
        } else {
            return nil
        }
    }
}
