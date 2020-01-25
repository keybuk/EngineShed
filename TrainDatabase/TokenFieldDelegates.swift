//
//  TokenFieldDelegates.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/20/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import AppKit

@objc
class DetailPartsTokenFieldDelegate : NSObject, NSTokenFieldDelegate {
    
    var model: Model
    
    init(model: Model) {
        self.model = model
        super.init()
    }
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return try? model.sortedValuesForDetailParts(startingWith: substring)
    }
    
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any? {
        if let detailPart = model.detailParts.first(where: { $0.title == editingString }) {
            return detailPart
        } else {
            return Model.DetailPart(title: editingString, isFitted: false)
        }
    }
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let detailPart = representedObject as? Model.DetailPart else { return nil }
        return detailPart.title + (detailPart.isFitted ? " ✓" : "")
    }
    
    func tokenField(_ tokenField: NSTokenField, editingStringForRepresentedObject representedObject: Any) -> String? {
        guard let detailPart = representedObject as? Model.DetailPart else { return nil }
        return detailPart.title
    }
    
    func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
        return true
    }
    
    func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
        guard let detailPart = representedObject as? Model.DetailPart else { return nil }

        let menu = NSMenu(title: detailPart.title)
        
        let item = NSMenuItem(title: "Fitted", action: nil, keyEquivalent: "")
        item.state = detailPart.isFitted ? .on : .off
        item.target = self
        item.action = #selector(isFittedChanged)
        item.representedObject = tokenField
        menu.addItem(item)
        
        return menu
    }
    
    @objc
    func isFittedChanged(_ sender: NSMenuItem) {
        // This is a little bit of a hack since we need the tokenField itself to alter its objects;
        // use the representedObject
        guard let title = sender.menu?.title else { fatalError("Couldn't steal title from menu") }
        let tokenField = sender.representedObject as! NSTokenField

        var detailParts = tokenField.objectValue as! [Model.DetailPart]
        guard let oldIndex = detailParts.firstIndex(where: { $0.title == title }) else { fatalError("Couldn't find token") }
        
        var detailPart = detailParts.remove(at: oldIndex)
        detailPart.isFitted = !detailPart.isFitted
        detailParts.insert(detailPart, at: oldIndex)
        
        tokenField.objectValue = detailParts
        model.detailParts = Set(detailParts)
    
        sender.state = detailPart.isFitted ? .on : .off
    }
    
}

