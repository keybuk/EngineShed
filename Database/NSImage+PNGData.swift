//
//  NSImage+PNGData.swift
//  Database macOS
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {

    func pngData() -> Data? {
        guard let imageData = self.tiffRepresentation else { return nil }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { return nil }
        return imageRep.representation(using: .png, properties: [:])
    }

}
