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
        return editingString
    }
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let title = representedObject as? String else { return nil }

        if let detailPart = model.detailPartForTitle(title) {
            return title + (detailPart.isFitted ? " ✓" : "")
        } else {
            return title
        }
    }
    
    func tokenField(_ tokenField: NSTokenField, editingStringForRepresentedObject representedObject: Any) -> String? {
        return representedObject as? String
    }
    
    func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
        return true
    }
    
    func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
        guard let title = representedObject as? String else { return nil }
        guard let detailPart = model.detailPartForTitle(title) else { return nil }

        let menu = NSMenu(title: detailPart.title!)
        
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
//        let tokenField = sender.representedObject as! NSTokenField

        if let detailPart = model.detailPartForTitle(title) {
            detailPart.isFitted = !detailPart.isFitted
            sender.state = detailPart.isFitted ? .on : .off

            try? model.managedObjectContext?.save() // FIXME
        }

//        var detailParts = tokenField.objectValue as! [DetailPart]
//        guard let oldIndex = detailParts.firstIndex(where: { $0.title == title }) else { fatalError("Couldn't find token") }
//
//        let detailPart = detailParts.remove(at: oldIndex)
//        detailPart.isFitted = !detailPart.isFitted
//        detailParts.insert(detailPart, at: oldIndex)
        
//        tokenField.objectValue = detailParts
//        model.detailPartsAsSet = Set(detailParts)
    }
    
}

