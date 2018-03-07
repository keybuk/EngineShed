//
//  WindowController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

extension NSStoryboard.SceneIdentifier {
    
    static let searchViewController = NSStoryboard.SceneIdentifier("searchViewController")
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
        sourceListViewController = splitViewController.splitViewItems[0].viewController as! SourceListViewController
        tabViewController = splitViewController.splitViewItems[1].viewController as! NSTabViewController
        
        let purchaseSplitViewController = tabViewController.childViewControllers[0] as! NSSplitViewController
        modelsViewController = purchaseSplitViewController.splitViewItems[0].viewController as! ModelsViewController
 
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

        let context = persistentContainer.viewContext

        var purchase = Purchase(context: context)
        let model = purchase.addModel()
        
        currentRecord = .model(model)
    }
    
    @IBAction func backupAction(_ sender: NSButton) {
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("Unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
                return
            }
        }

        do {
            try (NSApplication.shared.delegate! as! AppDelegate).backup()
        } catch {
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)
            return
        }

        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Backup complete."
        alert.addButton(withTitle: "OK")

        alert.runModal()
    }
    
    @IBAction func showFilter(_ sender: NSButton) {
        guard let searchViewController = storyboard?.instantiateController(withIdentifier: .searchViewController) as? SearchViewController else { return }

        let popover = NSPopover()
        popover.contentViewController = searchViewController
        popover.behavior = .transient
        popover.animates = true
        
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
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
    
    func sourceListDidSelect(modelClassification: ModelClassification) {
        tabViewController.selectedTabViewItemIndex = 0
        modelsViewController.setFilter(classification: modelClassification)
    }
    
    func sourceListDidSelectDecoders() {
        tabViewController.selectedTabViewItemIndex = 1
    }
    
}

