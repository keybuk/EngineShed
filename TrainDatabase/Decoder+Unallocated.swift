//
//  Decoder+Unallocated.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/25/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Decoder {
    /// Is the decoder not allocated to any model or sound file.
    var isUnallocated: Bool { model == nil && (soundProject?.isEmpty ?? true) }
}
