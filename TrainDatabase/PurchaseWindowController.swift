//
//  PurchaseWindowController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/2/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Cocoa

import Database

class PurchaseWindowController : NSWindowController, RecordController {

    var recordStack: [CurrentRecord] = []
    var recordIndex: Int = 0
    
    func currentRecordChanged() {
        guard let currentRecord = currentRecord else { return }
        guard case .model(let model) = currentRecord else { return }
        
        window?.title = model.purchase?.description ?? ""
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
