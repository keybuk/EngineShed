//
//  NSImage+Data.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import AppKit

extension NSImage {
    func pngData() -> Data? {
        guard let imageData = self.tiffRepresentation else { return nil }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { return nil }
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else { return nil }
        return pngData
    }
}
