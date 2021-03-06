//
//  DecoderType+WillSave.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension DecoderType {
    public override func willSave() {
        let newRemainingStock = makeRemainingStock()
        if remainingStock != newRemainingStock { remainingStock = newRemainingStock }
    }
}
