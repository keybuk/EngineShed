//
//  ModelsViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/15/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

import Database

extension NSUserInterfaceItemIdentifier {
    
    static let modelCell = NSUserInterfaceItemIdentifier("modelCell")
    static let modelGroupCell = NSUserInterfaceItemIdentifier("modelGroupCell")

}

extension NSStoryboard.SceneIdentifier {
    
    static let purchaseWindowController = "purchaseWindowController"
}

class ModelsViewController : NSViewController {
    
    @IBOutlet var tableView: NSTableView!

    var persistentContainer: NSPersistentContainer!
    
    var classificationFilter: Model.Classification?
    var searchFilter: String?
    
    var models: [Model]!
    var groups: [Int : String]!
    
    func setFilter(classification: Model.Classification) {
        classificationFilter = classification
        reloadData()
    }
    
    func setFilter(search: String?) {
        searchFilter = search
        reloadData()
    }

    func rowOf(_ model: Model, in models: [Model], groupOffsets: [Int]) -> Int? {
        guard let index = models.firstIndex(of: model) else { return nil }
        let groupOffset = groupOffsets.enumerated().count(where: { $1 - $0 <= index })
        return index + groupOffset
    }
    
    func rowOf(_ model: Model) -> Int? {
        return rowOf(model, in: models, groupOffsets: groups.keys.sorted())
    }
    
    func modelAt(_ row: Int) -> Model {
        let groupOffset = groups.count(where: { $0.key < row })
        let index = row - groupOffset
        return models[index]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistentContainer = (NSApplication.shared.delegate! as! AppDelegate).persistentContainer
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(currentRecordChanged), name: .currentRecordChanged, object: view.window)
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: persistentContainer.viewContext)
        
        reloadData()
    }
    
    @objc
    func currentRecordChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.selectCurrentRecord()
        }
    }
    
    @objc func managedObjectContextObjectsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.reloadData(notification: notification)
        }
    }
    
    func reloadData(notification: Notification? = nil) {
        //        let oldGroups = groups
        //        let oldModels = models

        if let search = searchFilter {
            models = try! Model.matching(search: search, in: persistentContainer.viewContext)
        } else if let classification = classificationFilter {
            models = try! Model.matching(classification: classification, in: persistentContainer.viewContext)
        } else {
            return
        }
        
        groups = [:]
        var lastClass: String? = nil
        for (index, model) in models.enumerated() {
            if lastClass == nil || model.modelClass != lastClass {
                groups[index + groups.count] = model.modelClass
                lastClass = model.modelClass
            }
        }
        
//        if let notification = notification, let oldGroups = oldGroups, let oldModels = oldModels, groups == oldGroups {
//            let (inserted, updated, deleted) = Model.changed(in: notification)
//
//            let oldGroupOffsets = oldGroups.keys.sorted()
//            let rowInOldGroupsOf = { (model: Model) -> Int? in
//                return self.rowOf(model, in: oldModels, groupOffsets: oldGroupOffsets)
//            }
//
//            tableView.beginUpdates()
//            tableView.noteNumberOfRowsChanged()
//
//            let insertedIndexes = IndexSet(inserted.flatMap(rowOf(_:)))
////            insertedIndexes.formUnion(IndexSet(groups.filter({ oldGroups[$0.key] == nil }).map({ $0.key })))
//            tableView.insertRows(at: insertedIndexes, withAnimation: .effectFade)
//
//            for updatedDecoderType in updated {
//                guard let newIndex = rowOf(updatedDecoderType) else { continue }
//                guard let oldIndex = rowInOldGroupsOf(updatedDecoderType) else { continue }
//
//                if oldIndex != newIndex {
//                    tableView.moveRow(at: oldIndex, to: newIndex)
//                }
//            }
//
//            let updatedIndexes = IndexSet(updated.flatMap(rowOf(_:)))
////            updatedIndexes.formUnion(IndexSet(groups.filter({ oldGroups[$0.key] != $0.value }).map({ $0.key })))
//            tableView.reloadData(forRowIndexes: updatedIndexes, columnIndexes: IndexSet(integer: 0))
//
//            let deletedIndexes = IndexSet(deleted.flatMap(rowInOldGroupsOf))
////            de3etedIndexes.formUnion(IndexSet(oldGroups.filter({ groups[$0.key] == nil }).map({ $0.key })))
//            tableView.removeRows(at: deletedIndexes, withAnimation: .effectFade)
//
//            tableView.endUpdates()
//        } else {
            tableView.reloadData()
//        }
        
        if tableView.selectedRow == -1 {
            selectCurrentRecord()
        }
    }
    
    func selectCurrentRecord() {
        if let currentRecord = recordController?.currentRecord,
            case .model(let model) = currentRecord {
            // Where the model has no classification (new record), clear the selection at all.
            guard let _ = model.classification else {
                tableView.deselectAll(nil)
                return
            }

            // Otherwise as long as it exists in the table, select it.
            if let row = rowOf(model) {
                tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                tableView.scrollRowToVisible(row)
                return
            }
        }
        
        // Fall back to selecting the first item.
        tableView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
    }
    
    @IBAction func openInNewWindow(_ sender: NSTableView) {
        guard let window = storyboard?.instantiateController(withIdentifier: .purchaseWindowController) as? PurchaseWindowController else { return }
        window.currentRecord = recordController?.currentRecord
        window.showWindow(nil)
    }

}

class ModelCellView : NSTableCellView {
    
    @IBOutlet var numberField: NSTextField?
    @IBOutlet var nameField: NSTextField?
    
}

extension ModelsViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // This gets called while the view is still loading, be sure to return 0.
        return (groups?.count ?? 0) + (models?.count ?? 0)
    }
    
}

extension ModelsViewController : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let _ = groups[row] {
            return 23
        } else {
            return 51
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let group = groups[row] {
            let view = tableView.makeView(withIdentifier: .modelGroupCell, owner: self) as! NSTableCellView
            view.textField?.stringValue = group
            return view

        } else {
            let model = modelAt(row)
            let view = tableView.makeView(withIdentifier: .modelCell, owner: self) as! ModelCellView
            
            view.imageView?.image = model.image
            view.numberField?.stringValue = model.number ?? ""
            view.numberField?.isHidden = model.number?.isEmpty ?? true
            view.nameField?.stringValue = model.name ?? ""
            view.nameField?.isHidden = model.name?.isEmpty ?? true
            
            return view
        }
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return groups[row] != nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        if let _ = groups[row] {
            rowView.backgroundColor = .headerColor
        }
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let _ = groups[row] {
            return false
        } else {
            return true
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { fatalError("Notification not from table view") }
        guard tableView.selectedRow >= 0 else { return }
        
        let model = modelAt(tableView.selectedRow)
        
        recordController?.currentRecord = .model(model)
    }
    
}
