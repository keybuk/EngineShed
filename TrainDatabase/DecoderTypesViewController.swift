//
//  DecoderTypesViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/27/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa

import Database

private extension NSUserInterfaceItemIdentifier {
    
    static let decoderTypeCell = NSUserInterfaceItemIdentifier("decoderTypeCell")
    
}

extension NSStoryboard.SceneIdentifier {
    
    static let decoderTypeWindowController = "decoderTypeWindowController"

}

class DecoderTypesViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    
    var persistentContainer: NSPersistentContainer!
    
    var decoderTypes: [DecoderType]!

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
//        let oldDecoderTypes = decoderTypes
        decoderTypes = try! DecoderType.all(in: persistentContainer.viewContext)

//        if let notification = notification, let oldDecoderTypes = oldDecoderTypes {
//            let (inserted, updated, deleted) = DecoderType.changed(in: notification)
//
//            tableView.beginUpdates()
//
//            let insertedIndexes = IndexSet(inserted.flatMap(decoderTypes.index(of:)))
//            tableView.insertRows(at: insertedIndexes, withAnimation: .effectFade)
//
//            for updatedDecoderType in updated {
//                guard let newIndex = decoderTypes.index(of: updatedDecoderType) else { continue }
//                guard let oldIndex = oldDecoderTypes.index(of: updatedDecoderType) else { continue }
//
//                if oldIndex != newIndex {
//                    tableView.moveRow(at: oldIndex, to: newIndex)
//                }
//            }
//
//            let updatedIndexes = IndexSet(updated.flatMap(decoderTypes.index(of:)))
//            tableView.reloadData(forRowIndexes: updatedIndexes, columnIndexes: IndexSet(integer: 0))
//
//            let deletedIndexes = IndexSet(deleted.flatMap(oldDecoderTypes.index(of:)))
//            tableView.removeRows(at: deletedIndexes, withAnimation: .effectFade)
//
//            tableView.endUpdates()
//
//        } else {
            tableView.reloadData()
//        }
        
        if tableView.selectedRow == -1 {
            selectCurrentRecord()
        }
    }
    
    func selectCurrentRecord() {
        if let currentRecord = recordController?.currentRecord,
            case .decoderType(let decoderType) = currentRecord,
            let row = decoderTypes.firstIndex(of: decoderType)
        {
            tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            tableView.scrollRowToVisible(row)
        } else {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
 
    @IBAction func openInNewWindow(_ sender: NSTableView) {
        guard let window = storyboard?.instantiateController(withIdentifier: .decoderTypeWindowController) as? DecoderTypeWindowController else { return }
        window.currentRecord = recordController?.currentRecord
        window.showWindow(nil)
    }

}

class DecoderTypeCellView : NSTableCellView {
    
    @IBOutlet var productField: NSTextField!
    @IBOutlet var familyField: NSTextField!
    @IBOutlet var socketField: NSTextField!
    @IBOutlet var countButton: NSButton!
    
}

extension DecoderTypesViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return decoderTypes?.count ?? 0
    }
    
}

extension DecoderTypesViewController : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { fatalError("Notification not from table view") }
        guard tableView.selectedRow >= 0 else { return }
        
        let decoderType = decoderTypes[tableView.selectedRow]
        
        recordController?.currentRecord = .decoderType(decoderType)
    }

}
