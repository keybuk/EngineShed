//
//  TrainMemberItem.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/24/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa

extension NSImage.Name {
    
    static let missingModelImage = "739-question"
}

class TrainMemberItem: NSCollectionViewItem {
    
    @IBOutlet var currentItemIndicator: NSBox!
    @IBOutlet var dropOnIndicator: NSBox!
    @IBOutlet var dropBeforeIndicator: NSBox!
    @IBOutlet var dropAfterIndicator: NSBox!
    
    @IBOutlet var titleField: NSTextField!
    
    var trainMember: TrainMember? {
        didSet {
            imageView?.image = trainMember?.model != nil ? trainMember?.image : NSImage(named: .missingModelImage)
            titleField.stringValue = trainMember?.title ?? ""
        }
    }
    
    var isCurrentItem: Bool = false {
        didSet {
            currentItemIndicator.isHidden = !isCurrentItem
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentItemIndicator.isHidden = true
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        
        dropOnIndicator.isHidden = true
        dropBeforeIndicator.isHidden = true
        dropAfterIndicator.isHidden = true
    }
    
    @IBAction func flipChanged(_ sender: NSMenuItem) {
        if var trainMember = trainMember {
            trainMember.isFlipped = !trainMember.isFlipped
            self.trainMember = trainMember
        }
    }
    
}

extension TrainMemberItem : NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        menu.item(at: 0)?.state = (trainMember?.isFlipped ?? false) ? .on : .off
    }
    
}
