//
//  RecordHeaderView.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/6/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Cocoa

class RecordHeaderView: NSView, NSCollectionViewElement {

    static let reuseIdentifier = NSUserInterfaceItemIdentifier("recordHeaderView")

    @IBOutlet weak var label: NSTextField?
    
}
