//
//  SourcesListViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/15/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa

import Database

extension NSUserInterfaceItemIdentifier {
    
    static let sourceCell = NSUserInterfaceItemIdentifier("sourceCell")
    static let sourceGroupCell = NSUserInterfaceItemIdentifier("sourceGroupCell")
    
}

private enum Group {
    case models
    case accessories
}

private enum Member {
    case decoders
}

protocol SourceListDelegate {
    
    func sourceListDidSelect(modelClassification: Model.Classification)
    func sourceListDidSelectDecoders()
    
}

class SourceListViewController : NSViewController {

    @IBOutlet var outlineView: NSOutlineView!
    
    var currentItem: Any? = Model.Classification.locomotive
    
    var delegate: SourceListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(currentRecordChanged), name: .currentRecordChanged, object: view.window)

        outlineView.expandItem(nil, expandChildren: true)
        selectCurrentItem()
    }
    
    @objc
    func currentRecordChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.selectCurrentRecord()
        }
    }

    func selectCurrentItem() {
        let row = outlineView.row(forItem: currentItem)
        if row != -1 {
            outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        }
    }
 
    func selectCurrentRecord() {
        guard let currentRecord = recordController?.currentRecord else { return }
        
        switch currentRecord {
        case .model(let model):
            // Clear the source list selection for a model without a classification (new model).
            guard let classification = model.classification else {
                outlineView.deselectAll(nil)
                break
            }
            
            currentItem = classification
            selectCurrentItem()
        case .decoderType(_):
            currentItem = Member.decoders
            selectCurrentItem()
        }
    }
    
    func searching() {
        outlineView.deselectAll(nil)
    }

}

extension SourceListViewController : NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch item {
        case nil:
            return 2
        case let group as Group:
            switch group {
            case .models:
                return 8
            case .accessories:
                return 2
            }
        default:
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        switch item {
        case nil:
            switch index {
            case 0:
                return Group.models
            case 1:
                return Group.accessories
            default:
                fatalError("Too many children in root group")
            }
        case let group as Group:
            switch group {
            case .models:
                switch index {
                case 0:
                    return Model.Classification.locomotive
                case 1:
                    return Model.Classification.steamLocomotive
                case 2:
                    return Model.Classification.coach
                case 3:
                    return Model.Classification.wagon
                case 4:
                    return Model.Classification.multipleUnit
                case 5:
                    return Model.Classification.departmental
                case 6:
                    return Model.Classification.noPrototype
                case 7:
                    return Model.Classification.vehicle
                default:
                    fatalError("Too many children in Models group")
                }
            case .accessories:
                switch index {
                case 0:
                    return Member.decoders
                case 1:
                    return Model.Classification.accessory
                default:
                    fatalError("Too many children in Accessories group")
                }
            }
        default:
            fatalError("Too many children in \(String(describing: item)) group")
        }
    
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case nil:
            return true
        case let group as Group:
            switch group {
            case .models:
                return true
            case .accessories:
                return true
            }
        default:
            return false
        }
    }
    
}

extension SourceListViewController : NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        switch item {
        case nil:
            return nil
        case let group as Group:
            let view = outlineView.makeView(withIdentifier: .sourceGroupCell, owner: self) as! NSTableCellView
            switch group {
            case .models:
                view.textField?.stringValue = "Models"
            case .accessories:
                view.textField?.stringValue = "Accessories"
            }
            return view
        case let classification as Model.Classification:
            let view = outlineView.makeView(withIdentifier: .sourceCell, owner: self) as! NSTableCellView
            switch classification {
            case .locomotive:
                view.textField?.stringValue = "Diesel & Electric Locomotives"
            case .steamLocomotive:
                view.textField?.stringValue = "Steam Locomotives"
            case .coach:
                view.textField?.stringValue = "Coaches"
            case .wagon:
                view.textField?.stringValue = "Wagons"
            case .multipleUnit:
                view.textField?.stringValue = "Multiple Units"
            case .departmental:
                view.textField?.stringValue = "Departmentals"
            case .noPrototype:
                view.textField?.stringValue = "No Prototype"
            case .accessory:
                view.textField?.stringValue = "Accessories"
            case .vehicle:
                view.textField?.stringValue = "Vehicles"
            }
            return view
        case let member as Member:
            let view = outlineView.makeView(withIdentifier: .sourceCell, owner: self) as! NSTableCellView
            switch member {
            case .decoders:
                view.textField?.stringValue = "Decoders"
            }
            return view
        default:
            fatalError("Unexpected item in outline view")
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        switch item {
        case is Group:
            return true
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        switch item {
        case is Model.Classification:
            return true
        case is Member:
            return true
        default:
            return false
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { fatalError("Notification not from outline view") }
        guard let item = outlineView.item(atRow: outlineView.selectedRow) else { return }
        currentItem = item
        
        switch item {
        case let classification as Model.Classification:
            delegate?.sourceListDidSelect(modelClassification: classification)
        case Member.decoders:
            delegate?.sourceListDidSelectDecoders()
        default:
            break
        }
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { fatalError("Notification not from outline view") }
        guard outlineView.selectedRow == -1 else { return }
        
        selectCurrentItem()
    }

}
