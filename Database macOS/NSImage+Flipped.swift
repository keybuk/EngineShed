//
//  NSImage+Flipped.swift
//  Database macOS
//
//  Created by Scott James Remnant on 6/18/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Cocoa

internal extension NSImage {

    internal func withHorizontallyFlippedOrientation() -> NSImage {
        let flipped = NSImage(size: size)
        flipped.lockFocus()

        let t = NSAffineTransform.init()
        t.translateX(by: (size.width), yBy: 0.0)
        t.scaleX(by: -1.0, yBy: 1.0)
        t.concat()

        draw(at: .zero, from: NSMakeRect(0, 0, size.width, size.height), operation: .sourceOver, fraction: 1.0)
        flipped.unlockFocus()

        return flipped
    }

}
