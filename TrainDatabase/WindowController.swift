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

extension NSToolbarItem.Identifier {
    static let trackingSeparatorIdentifier = NSToolbarItem.Identifier(rawValue: "TrackingSeparator")
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
        modelsViewController = (splitViewController.splitViewItems[1].viewController as! ModelsViewController)
        tabViewController = (splitViewController.splitViewItems[2].viewController as! NSTabViewController)
        
        sourceListViewController.delegate = self

        DispatchQueue.main.async {
            self.window?.toolbar?.insertItem(withItemIdentifier: .trackingSeparatorIdentifier, at: 1)
        }
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

        let managedObjectContext = persistentContainer.viewContext
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
        let managedObjectContext = persistentContainer.viewContext
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSApplication.shared.presentError(error)
            }
        }
    }

    @IBAction func backup(_ sender: NSButton) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: persistentContainer.managedObjectModel)
        managedObjectContext.persistentStoreCoordinator = coordinator

        let storeDescription = persistentContainer.persistentStoreDescriptions.last!
        let options: [AnyHashable: Any] = [
            NSReadOnlyPersistentStoreOption: true as NSNumber,
            NSInferMappingModelAutomaticallyOption: false as NSNumber,
            NSMigratePersistentStoresAutomaticallyOption: false as NSNumber,
            NSPersistentHistoryTrackingKey: true as NSNumber,
        ]

        let store = try! managedObjectContext.persistentStoreCoordinator!.addPersistentStore(ofType: storeDescription.type, configurationName: nil, at: storeDescription.url, options: options)

        managedObjectContext.performAndWait {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"

            let filename = "EngineShed Backup \(formatter.string(from: Date()))"
            let directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).last?
                .appendingPathComponent(filename, isDirectory: true)

            try! FileManager.default.createDirectory(at: directoryURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = directoryURL!.appendingPathComponent("EngineShed.sqlite")

            let options: [AnyHashable: Any] = [
                NSPersistentHistoryTrackingKey: true as NSNumber
            ]

            try! coordinator.migratePersistentStore(store, to: fileURL, options: options, withType: NSSQLiteStoreType)

            let alert = NSAlert()
            alert.messageText = "Saved"
            alert.informativeText = filename
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .informational
            alert.runModal()
        }

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
        modelsViewController.setFilterDecoderTypes()
        tabViewController.selectedTabViewItemIndex = 1
    }
    
}

extension WindowController : NSToolbarDelegate {

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == .trackingSeparatorIdentifier,
           let splitViewController = contentViewController as? NSSplitViewController {
            return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier, splitView: splitViewController.splitView, dividerIndex: 1)
        }

        return nil
    }

}
