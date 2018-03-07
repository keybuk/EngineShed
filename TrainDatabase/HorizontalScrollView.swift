//
//  HorizontalScrollView.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Cocoa

class HorizontalScrollView: NSScrollView {

    override func scrollWheel(with event: NSEvent) {
        guard abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) else {
            nextResponder?.scrollWheel(with: event)
            return
        }
        
        super.scrollWheel(with: event)
    }
    
}
