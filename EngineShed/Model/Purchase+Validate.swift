//
//  Purchase+Validate.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/3/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension Purchase {

    enum ValidationError : Error {

        /// Purchase manufacturer may not be empty.
        case emptyManufacturer

        /// Purchase catalogNumber may not be empty.
        case emptyCatalogNumber

    }

    @objc
    func validateManufacturer(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let manufacturer = value.pointee as? String, manufacturer != "" else { throw ValidationError.emptyManufacturer }
    }

    @objc
    func validateCatalogNumber(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let catalogNumber = value.pointee as? String, catalogNumber != "" else { throw ValidationError.emptyCatalogNumber }
    }

}
