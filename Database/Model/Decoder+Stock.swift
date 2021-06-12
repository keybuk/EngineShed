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
        (soundAuthor ?? "") != "" ||
            (soundProject ?? "") != "" ||
            (soundProjectVersion ?? "") != "" ||
            (soundSettings ?? "") != ""
    }

    /// Returns `true` if the decoder is not fitted to any model or allocated a sound file.
    public var isSpare: Bool { !isFitted && !isAllocated }

    public func updateStock() {
        guard let decoderType = type else { return }
        let remainingStock = decoderType.makeRemainingStock()
        if decoderType.remainingStock != remainingStock {
            decoderType.remainingStock = remainingStock
        }
    }
}
