//
//  TrainMember+NSImage.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/24/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import AppKit

extension NSImage {
    
    public func flippedHorizontally() -> NSImage {
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


extension TrainMember {
    
    var image: NSImage? {
        guard let originalImage = model?.image else { return nil }
        return isFlipped ? originalImage.flippedHorizontally() : originalImage
    }
    
}
