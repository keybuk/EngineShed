//
//  Train+Validate.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension Train {

    enum ValidationError : Error {

        /// Train name may not be empty.
        case emptyName

        /// Train must have at least one member.
        case noMembers

    }

    @objc
    func validateName(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let name = value.pointee as? String, name != "" else { throw ValidationError.emptyName }
    }

//    func validateMembers() throws {
//        guard members!.count > 0 else { throw ValidationError.noMembers }
//    }
//
//    override func validateForInsert() throws {
//        try super.validateForInsert()
//        try validateMembers()
//    }
//
//    override func validateForUpdate() throws {
//        try super.validateForUpdate()
//        try validateMembers()
//    }

}
