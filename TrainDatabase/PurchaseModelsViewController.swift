//
//  PurchaseModelsViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

import Database

extension NSUserInterfaceItemIdentifier {
    
    static let purchaseModelCell = NSUserInterfaceItemIdentifier("purchaseModelCell")
    
}

private extension NSPasteboard.PasteboardType {
    
    static let purchaseModelRow = NSPasteboard.PasteboardType("com.netsplit.TrainDatabase.PurchaseModel")
    
}

class PurchaseModelsViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!

    var persistentContainer: PersistentContainer!
    var managedObjectContext: NSManagedObjectContext?

    var purchase: Purchase!
    var models: [Model] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerForDraggedTypes([ .purchaseModelRow ])

        persistentContainer = (NSApplication.shared.delegate! as! AppDelegate).persistentContainer
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(currentRecordChanged), name: .currentRecordChanged, object: view.window)
        notificationCenter.addObserver(self, selector: #selector(saveChanges), name: .saveChanges, object: NSApplication.shared)

        updateCurrentRecord()
    }
    
    @objc
    func currentRecordChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateCurrentRecord()
        }
    }

    @objc
    func saveChanges(_ notification: Notification) {
        self.saveAnyChanges()
    }

    func saveAnyChanges() {
        if let managedObjectContext = managedObjectContext, managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSApplication.shared.presentError(error)
            }
        }
    }

    func updateCurrentRecord() {
        saveAnyChanges()
        
        guard let currentRecord = recordController?.currentRecord else { return }
        guard case .model(let model) = currentRecord else { return }
        guard let purchase = model.purchase else { return }

        managedObjectContext = persistentContainer.newEditingContext()
        self.purchase = managedObjectContext!.object(with: purchase.objectID) as? Purchase

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext!)

        models = purchase.models()
        reloadData()
    }
    
    @objc func managedObjectContextObjectsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.reloadData(notification: notification)
        }
    }
    
    func reloadData(notification: Notification? = nil) {
//        if let notification = notification {
//            // This table has a simplified approach to reloading because it's directly based off the models list in the purchase,
//            // which is an ordered array of entries. Sort order is thus only changed on add/remove, so we can get away without
//            // doing any of the complicated stuff!
//            let (inserted, updated, deleted) = Model.changed(in: notification)
//
//            tableView.beginUpdates()
//
//            let insertedIndexes = IndexSet(inserted.flatMap(purchase.models.index(of:)))
//            tableView.insertRows(at: insertedIndexes, withAnimation: .effectFade)
//
//            let updatedIndexes = IndexSet(updated.flatMap(purchase.models.index(of:)))
//            tableView.reloadData(forRowIndexes: updatedIndexes, columnIndexes: IndexSet(integer: 0))
//
//            let deletedIndexes = IndexSet(deleted.flatMap(purchase.models.index(of:)))
//            tableView.removeRows(at: deletedIndexes, withAnimation: .effectFade)
//
//            tableView.endUpdates()
//        } else {
            tableView.reloadData()
//        }
        
        if self.tableView.selectedRow == -1 {
            self.selectCurrentRecord()
        }
    }
    
    func selectCurrentRecord() {
        guard let currentRecord = recordController?.currentRecord else { return }
        guard case .model(let model) = currentRecord else { return }
        guard let row = models.firstIndex(of: model) else { return }
        
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
    
    @IBAction func addModel(_ sender: NSButton) {
        // Clear the current responder first (end editing).
        guard view.window?.makeFirstResponder(nil) ?? true else { return }

        let managedObjectContext = persistentContainer.newBackgroundContext()

        managedObjectContext.performAndWait {
            let purchase = managedObjectContext.object(with: self.purchase.objectID) as! Purchase
            let model = purchase.addModel()

            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSApplication.shared.presentError(error)
            }

            models = purchase.models()
            guard let row = models.firstIndex(of: model) else { fatalError("Model we just added wasn't in the list") }

            tableView.insertRows(at: IndexSet(integer: row) , withAnimation: .effectFade)
            tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        }
    }
    
}

extension PurchaseModelsViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: .purchaseModelRow)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldRows: [Int] = []
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
            (draggingItem, idx, stop) in
            guard let item = draggingItem.item as? NSPasteboardItem else { return }
            guard let rowStr = item.string(forType: .purchaseModelRow) else { return }
            guard let row = Int(rowStr) else { return }
            
            oldRows.append(row)
        }
        
        var oldRowOffset = 0
        var newRowOffset = 0
        
        tableView.beginUpdates()
        for oldRow in oldRows {
            if oldRow < row {
                purchase.moveModelAt(oldRow + oldRowOffset, to: row - 1)
                tableView.moveRow(at: oldRow + oldRowOffset, to: row - 1)
                oldRowOffset -= 1
            } else {
                purchase.moveModelAt(oldRow, to: row + newRowOffset)
                tableView.moveRow(at: oldRow, to: row + newRowOffset)
                newRowOffset += 1
            }
        }
        models = purchase.models()

        tableView.endUpdates()
        return true
    }
    
}

extension PurchaseModelsViewController : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: .purchaseModelCell, owner: self) as! NSTableCellView
        let model = models[row]
        
        view.imageView?.image = model.image
        view.textField?.stringValue = model.modelClass ?? ""
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { fatalError("Notification not from table view") }
        guard tableView.selectedRow >= 0 else { return }

        let model = models[tableView.selectedRow]
        
        recordController?.currentRecord = .model(model)
    }
    
}
