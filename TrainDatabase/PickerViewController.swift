//
//  PickerViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/23/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa

private extension NSUserInterfaceItemIdentifier {
    
    static let pickerCell = NSUserInterfaceItemIdentifier("pickerCell")
    
}

class PickerViewController: NSViewController {

    @IBOutlet var searchField: NSSearchField!
    @IBOutlet var tableView: NSTableView!
    
    var values: [String] = []
    var filteredValues: [String] = []
    var setValues: Set<String> = Set()
    
    var updateBlock: ((Set<String>) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.centersPlaceholder = false
    }
    
    func pick(for view: NSView, from values: @autoclosure () -> [String], setValues: @autoclosure () -> Set<String>, onUpdate block: @escaping (Set<String>) -> Void) {
        // Clear the current responder first (end editing).
        guard view.window?.makeFirstResponder(nil) ?? true else { return }

        self.values = values()
        self.filteredValues = self.values
        self.setValues = setValues()
        self.updateBlock = block
        
        let popover = NSPopover()
        popover.contentViewController = self
        popover.behavior = .transient
        popover.animates = true
        
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
    
    @IBAction func searchFieldChanged(_ sender: NSSearchField) {
        if !sender.stringValue.isEmpty {
            filteredValues = values.filter({ $0.lowercased().contains(sender.stringValue.lowercased() )})
        } else {
            filteredValues = values
        }
        
        tableView.reloadData()
        if tableView.selectedRow == -1 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    @IBAction func tableViewAction(_ sender: NSTableView) {
        guard tableView.selectedRow >= 0 else { return }
        let row = tableView.selectedRow
        
        let value = filteredValues[row]
        if setValues.contains(value) {
            setValues.remove(value)
        } else {
            setValues.insert(value)
        }
        
        tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
        
        updateBlock(setValues)
    }
    
    @IBAction func addButtonAction(_ sender: NSButton) {
        let value = searchField.stringValue
        
        if value.isEmpty || values.contains(where: { $0.lowercased() == value.lowercased() }) {
            NSSound.beep()
            return
        }
        
        values.append(value)
        values.sort()

        setValues.insert(value)
        
        searchField.stringValue = ""
        filteredValues = values

        tableView.reloadData()
    
        updateBlock(setValues)
    }
    
}

extension PickerViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredValues.count
    }
    
}

extension PickerViewController : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let value = filteredValues[row]
        
        let view = tableView.makeView(withIdentifier: .pickerCell, owner: self) as! PickerCellView
        view.textField?.stringValue = value
        view.checkboxTextField?.isHidden = !setValues.contains(value)
        return view
    }
    
}

extension PickerViewController : NSSearchFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(insertNewline(_:)):
            guard tableView.selectedRow >= 0 else { return false }
            
            let value = filteredValues[tableView.selectedRow]
            control.stringValue = value
            
            // Not sure if this is the right way to do this.
            if let action = tableView.action, let target = tableView.target {
                NSApplication.shared.sendAction(action, to: target, from: self)
            }
            
            return true
        case #selector(moveUp(_:)):
            guard tableView.selectedRow > 0 else { return false }
            
            tableView.selectRowIndexes(IndexSet(integer: tableView.selectedRow - 1), byExtendingSelection: false)
            return true
        case #selector(moveDown(_:)):
            guard tableView.selectedRow < (tableView.numberOfRows - 1) else { return false }
            
            tableView.selectRowIndexes(IndexSet(integer: tableView.selectedRow + 1), byExtendingSelection: false)
            return true
        default:
            return false
        }
    }
}

class PickerCellView : NSTableCellView {
    
    @IBOutlet var checkboxTextField: NSTextField!
    
}
