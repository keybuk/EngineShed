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
    static let decoderTypeCell = NSUserInterfaceItemIdentifier("decoderTypeCell")
}

extension NSStoryboard.SceneIdentifier {
    static let purchaseWindowController = "purchaseWindowController"
    static let decoderTypeWindowController = "decoderTypeWindowController"
}

class ModelsViewController : NSViewController {
    
    @IBOutlet var tableView: NSTableView!

    var persistentContainer: NSPersistentContainer!
    
    var classificationFilter: Model.Classification?
    var searchFilter: String?
    
    var models: [Model]!
    var modelGroups: [Int : String]!

    var decoderTypes: [DecoderType]!

    func setFilterDecoderTypes() {
        classificationFilter = nil
        reloadData()
    }

    func setFilter(classification: Model.Classification) {
        classificationFilter = classification
        reloadData()
    }
    
    func setFilter(search: String?) {
        classificationFilter = nil
        searchFilter = search
        reloadData()
    }

    func rowOf(_ model: Model, in models: [Model], groupOffsets: [Int]) -> Int? {
        guard let index = models.firstIndex(of: model) else { return nil }
        let groupOffset = groupOffsets.enumerated().count(where: { $1 - $0 <= index })
        return index + groupOffset
    }
    
    func rowOf(_ model: Model) -> Int? {
        return rowOf(model, in: models, groupOffsets: modelGroups.keys.sorted())
    }
    
    func modelAt(_ row: Int) -> Model {
        let groupOffset = modelGroups.count(where: { $0.key < row })
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
        if let search = searchFilter {
            let fetchRequest = Model.fetchRequestForModels(matching: search)
            reloadModels(fetchRequest: fetchRequest)
        } else if let classification = classificationFilter {
            let fetchRequest = Model.fetchRequestForModels(classification: classification)
            reloadModels(fetchRequest: fetchRequest)
        } else {
            let fetchRequest = DecoderType.fetchRequestForDecoderTypes()
            reloadDecoderTypes(fetchRequest: fetchRequest)
        }

        tableView.reloadData()

        if tableView.selectedRow == -1 {
            selectCurrentRecord()
        }
    }

    func reloadModels(fetchRequest: NSFetchRequest<Model>) {
        decoderTypes = []

        persistentContainer.viewContext.performAndWait {
            models = try! fetchRequest.execute()
        }

        modelGroups = [:]
        var lastClass: String? = nil
        for (index, model) in models.enumerated() {
            if lastClass == nil || model.modelClass != lastClass {
                modelGroups[index + modelGroups.count] = model.modelClass
                lastClass = model.modelClass
            }
        }

        switch classificationFilter {
        case .locomotive:
            view.window?.title = "Locomotives"
        case .coach:
            view.window?.title = "Coaches"
        case .wagon:
            view.window?.title = "Wagons"
        case .multipleUnit:
            view.window?.title = "Multiple Units"
        case .departmental:
            view.window?.title = "Departmentals"
        case .noPrototype:
            view.window?.title = "No Prototype"
        case .accessory:
            view.window?.title = "Accessories"
        case .vehicle:
            view.window?.title = "Vehicles"
        default:
            view.window?.title = "Models"
        }

        view.window?.subtitle = "\(models.count) Model\(models.count == 1 ? "" : "s")"
    }

    func reloadDecoderTypes(fetchRequest: NSFetchRequest<DecoderType>) {
        models = []
        modelGroups = [:]

        persistentContainer.viewContext.performAndWait {
            decoderTypes = try! fetchRequest.execute()
        }

        view.window?.title = classificationFilter?.description ?? "Decoders"
        view.window?.subtitle = "\(decoderTypes.count) Type\(decoderTypes.count == 1 ? "" : "s")"
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
////            insertedIndexes.formUnion(IndexSet(groups.filter({ oldGroups[$0.key] == nil }).map(\.key)))
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
////            updatedIndexes.formUnion(IndexSet(groups.filter({ oldGroups[$0.key] != $0.value }).map(\.key)))
//            tableView.reloadData(forRowIndexes: updatedIndexes, columnIndexes: IndexSet(integer: 0))
//
//            let deletedIndexes = IndexSet(deleted.flatMap(rowInOldGroupsOf))
////            de3etedIndexes.formUnion(IndexSet(oldGroups.filter({ groups[$0.key] == nil }).map(\.key)))
//            tableView.removeRows(at: deletedIndexes, withAnimation: .effectFade)
//
//            tableView.endUpdates()
//        } else {
//        }
//    }
    
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
        } else if let currentRecord = recordController?.currentRecord,
                  case .decoderType(let decoderType) = currentRecord,
                  let row = decoderTypes.firstIndex(of: decoderType) {
                      tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                      tableView.scrollRowToVisible(row)
        } else {
            // Fall back to selecting the first item.
            tableView.selectRowIndexes(IndexSet(integer: classificationFilter == nil ? 0 : 1), byExtendingSelection: false)
        }
    }
    
    @IBAction func openInNewWindow(_ sender: NSTableView) {
        guard let currentRecord = recordController?.currentRecord else { return }
        if case .model(_) = currentRecord {
            guard let window = storyboard?.instantiateController(withIdentifier: .purchaseWindowController) as? PurchaseWindowController else { return }
            window.currentRecord = recordController?.currentRecord
            window.showWindow(nil)
        } else if case .decoderType(_) = currentRecord {
            guard let window = storyboard?.instantiateController(withIdentifier: .decoderTypeWindowController) as? DecoderTypeWindowController else { return }
            window.currentRecord = recordController?.currentRecord
            window.showWindow(nil)
        }
    }

}

class ModelCellView : NSTableCellView {
    @IBOutlet var numberField: NSTextField?
    @IBOutlet var nameField: NSTextField?
}

class DecoderTypeCellView : NSTableCellView {
    @IBOutlet var productField: NSTextField!
    @IBOutlet var familyField: NSTextField!
    @IBOutlet var socketField: NSTextField!
    @IBOutlet var countButton: NSButton!
}

extension ModelsViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if classificationFilter != nil || searchFilter != nil {
            // This gets called while the view is still loading, be sure to return 0.
            return (modelGroups?.count ?? 0) + (modelGroups?.count ?? 0)
        } else {
            return decoderTypes?.count ?? 0
        }
    }
    
}

extension ModelsViewController : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if classificationFilter != nil || searchFilter != nil {
            if let _ = modelGroups[row] {
                return 23
            } else {
                return 51
            }
        } else {
            return 59
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if classificationFilter != nil || searchFilter != nil {
            if let group = modelGroups[row] {
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
        } else {
            let decoderType = decoderTypes[row]

            let view = tableView.makeView(withIdentifier: .decoderTypeCell, owner: self) as! DecoderTypeCellView

            view.productField.stringValue = [ decoderType.manufacturer, decoderType.productCode ].compactMap({ $0 }).joined(separator: " ")

            view.familyField.stringValue = decoderType.productFamily ?? ""
            view.familyField.isHidden = decoderType.productFamily?.isEmpty ?? true

            view.socketField.stringValue = decoderType.socket ?? ""

            view.countButton.title = "\(decoderType.remainingStockAsString)"
            view.countButton.isHidden = !decoderType.isStocked

            return view
        }
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if classificationFilter != nil || searchFilter != nil {
            return modelGroups[row] != nil
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if classificationFilter != nil || searchFilter != nil {
            if let _ = modelGroups[row] {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { fatalError("Notification not from table view") }
        guard tableView.selectedRow >= 0 else { return }

        if classificationFilter != nil || searchFilter != nil {
            let model = modelAt(tableView.selectedRow)
        
            recordController?.currentRecord = .model(model)
        } else {
            let decoderType = decoderTypes[tableView.selectedRow]

            recordController?.currentRecord = .decoderType(decoderType)
        }
    }
    
}
