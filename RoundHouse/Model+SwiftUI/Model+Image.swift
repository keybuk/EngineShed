//
//  Model+Image.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI

import Database

extension Model {
    var image: Image? {
        guard let imageData = imageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        else { return nil }

        return Image(decorative: cgImage, scale: 1.0)
    }
}
