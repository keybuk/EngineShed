//
//  ModelItem.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/6/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Cocoa

class ModelItem: NSCollectionViewItem {

    static let reuseIdentifier = NSUserInterfaceItemIdentifier("modelItem")

    @IBOutlet weak var numberTextField: NSTextField?
    @IBOutlet weak var nameTextField: NSTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        imageView?.wantsLayer = true
        imageView?.layer?.backgroundColor = CGColor.white
        imageView?.layer?.cornerRadius = 8.0
        imageView?.layer?.masksToBounds = true
    }

    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            updateSelectionHighlighting()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateSelectionHighlighting()
        }
    }

    private func updateSelectionHighlighting() {
        if !isViewLoaded {
            return
        }

        let showAsHighlighted = (highlightState == .forSelection) ||
            (isSelected && highlightState != .forDeselection) ||
            (highlightState == .asDropTarget)

        numberTextField?.textColor = showAsHighlighted ? .alternateSelectedControlTextColor : .labelColor
        nameTextField?.textColor = showAsHighlighted ? .alternateSelectedControlTextColor : .labelColor
        view.layer?.backgroundColor = showAsHighlighted ? NSColor.selectedContentBackgroundColor.cgColor : nil
    }

}
