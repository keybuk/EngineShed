//
//  DecoderType+Decoders.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension DecoderType {

    func addDecoder(_ decoder: Decoder) {
        addToDecoders(decoder)
    }

    func removeDecoder(_ decoder: Decoder) {
        removeFromDecoders(decoder)
    }

    func moveDecoder(from fromIndex: Int, to toIndex: Int) {

    }

}
