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

    /// Any change to `DetailPart` is mapepd to a change in `Model.detailPartsFitted`.
    ///
    /// Since `isFitted` is the only mutable value, this is the only key that needs to be updated;
    /// adding or removing a detail part already results in `Model.detailParts` changing.
    var mappedKeys: Set<String> { return [ "detailPartsFitted" ] }

}
