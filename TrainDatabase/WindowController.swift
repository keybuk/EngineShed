//
//  WindowController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

import Database

extension NSStoryboard.SceneIdentifier {
    
    static let searchViewController = "searchViewController"
}

class WindowController : NSWindowController, RecordController {

    @IBOutlet var navigationControl: NSSegmentedControl!
    @IBOutlet var searchField: NSSearchField!

    var persistentContainer: NSPersistentContainer!

    var sourceListViewController: SourceListViewController!
    var tabViewController: NSTabViewController!
    var modelsViewController: ModelsViewController!
    
    var recordStack: [CurrentRecord] = []
    var recordIndex: Int = 0
    
    func currentRecordChanged() {
        navigationControl.setEnabled(recordIndex > recordStack.startIndex, forSegment: 0)
        navigationControl.setEnabled(recordIndex < recordStack.index(before: recordStack.endIndex), forSegment: 1)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        persistentContainer = (NSApplication.shared.delegate! as! AppDelegate).persistentContainer
        
        // View hierarchy:
        //   Split View
        //   +- Source List
        //   +- Tab View
        //      +- Split View (purchase)
        //         +- Models View
        //         +- Purchase View
        
        let splitViewController = contentViewController as! NSSplitViewController
        sourceListViewController = (splitViewController.splitViewItems[0].viewController as! SourceListViewController)
        tabViewController = (splitViewController.splitViewItems[1].viewController as! NSTabViewController)
        
        let purchaseSplitViewController = tabViewController.children[0] as! NSSplitViewController
        modelsViewController = (purchaseSplitViewController.splitViewItems[0].viewController as! ModelsViewController)
 
        sourceListViewController.delegate = self
    }
    
    @IBAction func navigation(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            recordIndex = recordStack.index(before: recordIndex)
        case 1:
            recordIndex = recordStack.index(after: recordIndex)
        default:
            fatalError("There are only two segments")
        }
        
        recordIndexChanged()
    }
    
    @IBAction func addPurchase(_ sender: NSButton) {
        // Clear the current responder first (end editing).
        guard window?.makeFirstResponder(nil) ?? true else { return }

        let managedObjectContext = persistentContainer.newBackgroundContext()

        managedObjectContext.performAndWait {
            let purchase = Purchase(context: managedObjectContext)
            let model = purchase.addModel()

            do {
                try managedObjectContext.save()

                self.currentRecord = .model(model)
            } catch let error as NSError {
                NSApplication.shared.presentError(error)
            }
        }
    }
    
    @IBAction func save(_ sender: NSButton) {
        NotificationCenter.default.post(name: .saveChanges, object: sender)
    }
    
    @IBAction func search(_ sender: NSSearchField) {
        guard !sender.stringValue.isEmpty else {
            modelsViewController.setFilter(search: nil)
            return
        }

        sourceListViewController.searching()
        tabViewController.selectedTabViewItemIndex = 0
        modelsViewController.setFilter(search: sender.stringValue)
    }
    
}

extension WindowController : SourceListDelegate {
    
    func sourceListDidSelect(modelClassification: Model.Classification) {
        tabViewController.selectedTabViewItemIndex = 0
        modelsViewController.setFilter(classification: modelClassification)
    }
    
    func sourceListDidSelectDecoders() {
        tabViewController.selectedTabViewItemIndex = 1
    }
    
}

