//
//  TrainMember+Validate.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import CoreData

extension TrainMember {

    enum ValidationError : Error {

        /// Train member title may not be empty.
        case emptyTitle

    }

    @objc
    func validateTitle(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let title = value.pointee as? String, title != "" else { throw ValidationError.emptyTitle }
    }

}
