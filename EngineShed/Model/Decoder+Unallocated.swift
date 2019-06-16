//
//  Decoder+Unallocated.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Decoder {

    /// Returns `true` if the decoder is not allocated to any model or sound file.
    var isUnallocated: Bool {
        return model == nil && (soundProject?.isEmpty ?? true)
    }

}
