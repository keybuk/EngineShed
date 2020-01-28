//
//  EnterTableView.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Cocoa

class EnterTableView: NSTableView {

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 0x24, let action = action, let target = target {
            // Not sure if this is the right way to do this.
            NSApplication.shared.sendAction(action, to: target, from: self)
        } else {
            super.keyDown(with: event)
        }
    }

}
