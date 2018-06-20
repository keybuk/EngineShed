//
//  CloudMappable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/19/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit

protocol CloudMappable : class {

    /// Underlying object that this object maps to.
    var mappedObject: CloudStorable? { get }

    /// Keys of `mappedObject` that should be changed when this object is changed.
    var mappedKeys: Set<String> { get }

}
