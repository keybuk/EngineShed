//
//  DecoderType+Derived.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/25/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension DecoderType {
    func makeRemainingStock() -> Int16 {
        guard let decoders = decoders as? Set<Decoder> else { return 0 }
        return Int16(clamping: decoders.count(where: { $0.isUnallocated }))
    }

    public override func willSave() {
        let newRemainingStock = makeRemainingStock()
        if remainingStock != newRemainingStock { remainingStock = newRemainingStock }
    }
}
