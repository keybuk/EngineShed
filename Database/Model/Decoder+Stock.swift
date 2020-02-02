//
//  Decoder+Unallocated.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Decoder {
    /// Returns `true` if the decoder is fitted to a model.
    public var isFitted: Bool { model != nil }

    /// Returns `true` if the decoder has a sound project allocated or written to it.
    public var isAllocated: Bool {
        !(soundAuthor?.isEmpty ?? true) ||
            !(soundProject?.isEmpty ?? true) ||
            !(soundProjectVersion?.isEmpty ?? true) ||
            !(soundSettings?.isEmpty ?? true)
    }

    /// Returns `true` if the decoder is not allocated to any model or sound file.
    public var isSpare: Bool { !isFitted && !isAllocated }
}
