//
//  DetailPart+CloudMappable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/19/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension DetailPart : CloudMappable {

    /// Changes to `DetailPart` are mapped to a change in `Model`.
    var mappedObject: CloudStorable? { return model }

    /// Any change to `DetailPart` is mapped to a change in `Model.detailParts`.
    ///
    /// Model handles updating both the "detailParts" and "detailPartsFitted" lists when that
    /// relationship field is changed.
    var mappedKeys: Set<String> { return [ "detailParts" ] }

}
