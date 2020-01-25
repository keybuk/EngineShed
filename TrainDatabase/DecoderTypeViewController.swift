    //
//  DecoderTypeViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/27/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa

private extension NSUserInterfaceItemIdentifier {
    
    static let serialNumberColumn = NSUserInterfaceItemIdentifier("serialNumberColumn")
    static let serialNumberCell = NSUserInterfaceItemIdentifier("serialNumberCell")
    static let firmwareVersionColumn = NSUserInterfaceItemIdentifier("firmwareVersionColumn")
    static let firmwareVersionCell = NSUserInterfaceItemIdentifier("firmwareVersionCell")
    static let firmwareDateColumn = NSUserInterfaceItemIdentifier("firmwareDateColumn")
    static let firmwareDateCell = NSUserInterfaceItemIdentifier("firmwareDateCell")
    static let addressColumn = NSUserInterfaceItemIdentifier("addressColumn")
    static let addressCell = NSUserInterfaceItemIdentifier("addressCell")
    static let soundAuthorColumn = NSUserInterfaceItemIdentifier("soundAuthorColumn")
    static let soundAuthorCell = NSUserInterfaceItemIdentifier("soundAuthorCell")
    static let soundProjectColumn = NSUserInterfaceItemIdentifier("soundProjectColumn")
    static let soundProjectCell = NSUserInterfaceItemIdentifier("soundProjectCell")

}

class DecoderTypeViewController: NSViewController {
    
    @IBOutlet var manufacturerComboBox: NSComboBox!
    @IBOutlet var productCodeTextField: NSTextField!
    @IBOutlet var productFamilyComboBox: NSComboBox!
    @IBOutlet var productDescriptionTextField: NSTextField!
    @IBOutlet var socketComboBox: NSComboBox!
    @IBOutlet var isProgrammableCheckBox: NSButton!
    @IBOutlet var hasSoundCheckBox: NSButton!
    @IBOutlet var hasRailComCheckBox: NSButton!
    @IBOutlet var minimumStockTextField: NSTextField!
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var removeButton: NSButton!
    
    var manufacturerComboBoxDataSource: SimpleComboBoxDataSource?
    var productFamilyComboBoxDataSource: SimpleComboBoxDataSource?
    var socketComboBoxDataSource: SimpleComboBoxDataSource?
    
    var decoderType: DecoderType!
    var decoders: [Decoder]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.sortDescriptors = [ NSSortDescriptor(key: "serialNumber", ascending: true) ]
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(currentRecordChanged), name: .currentRecordChanged, object: view.window)
        
        updateCurrentRecord()
    }
    
    @objc
    func currentRecordChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateCurrentRecord()
        }
    }
    
    func updateCurrentRecord() {
        guard let currentRecord = recordController?.currentRecord else { return }
        guard case .decoderType(let decoderType) = currentRecord else { return }
        
        self.decoderType = decoderType
        decoders = Array(decoderType.unallocatedDecoders())
        sortDecoders()
        
        reloadData()
        
        if decoderType.manufacturer.isEmpty {
            view.window?.makeFirstResponder(manufacturerComboBox)
        }
    }
    
    func sortDecoders() {
        guard let sortDescriptor = tableView.sortDescriptors.first else { return }
        // This gets called in viewDidLoad() because we set sort descriptors there.
        guard let _ = decoders else { return }
        
        switch sortDescriptor.key! {
        case "serialNumber":
            decoders.sort(by: { $0.serialNumber < $1.serialNumber })
        case "firmwareVersion":
            decoders.sort(by: { $0.firmwareVersion < $1.firmwareVersion })
        case "firmwareDate":
            decoders.sort(by: { ($0.firmwareDate ?? Date.distantPast) < ($1.firmwareDate ?? Date.distantPast) })
        case "address":
            decoders.sort(by: { $0.address < $1.address })
        case "soundAuthor":
            decoders.sort(by: { $0.soundAuthor < $1.soundAuthor })
        case "soundProject":
            decoders.sort(by: { $0.soundProject < $1.soundProject })
        default:
            break
        }
        
        if !sortDescriptor.ascending {
            decoders.reverse()
        }
    }

    func reloadData() {
        manufacturerComboBoxDataSource = try? SimpleComboBoxDataSource(using: decoderType.sortedValuesForManufacturer)
        manufacturerComboBox.dataSource = manufacturerComboBoxDataSource
        manufacturerComboBox.stringValue = decoderType.manufacturer

        productCodeTextField.stringValue = decoderType.productCode

        productFamilyComboBoxDataSource = try? SimpleComboBoxDataSource(using: decoderType.sortedValuesForProductFamily)
        productFamilyComboBox.dataSource = productFamilyComboBoxDataSource
        productFamilyComboBox.stringValue = decoderType.productFamily

        productDescriptionTextField.stringValue = decoderType.productDescription

        socketComboBoxDataSource = try? SimpleComboBoxDataSource(using: decoderType.sortedValuesForSocket)
        socketComboBox.dataSource = socketComboBoxDataSource
        socketComboBox.stringValue = decoderType.socket

        isProgrammableCheckBox.state = decoderType.isProgrammable ? .on : .off
        hasSoundCheckBox.state = decoderType.hasSound ? .on : .off
        hasRailComCheckBox.state = decoderType.hasRailCom ? .on : .off
        minimumStockTextField.objectValue = decoderType.minimumStock != 0 ? decoderType.minimumStock : nil
        
        tableView.reloadData()
    }
    
    @IBAction func addRecord(_ sender: NSButton) {
        let decoder = decoderType.addDecoder()
        decoders.append(decoder)
        
        let indexSet = IndexSet(integer: decoders.count - 1)
        
        tableView.insertRows(at: indexSet, withAnimation: .slideDown)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
        
        tableView.editColumn(0, row: decoders.count - 1, with: nil, select: true)
    }
    
    @IBAction func removeRecord(_ sender: NSButton) {
        guard tableView.selectedRow >= 0 else { return }

        let alert = NSAlert()
        alert.messageText = "Delete the decoder?"
        alert.informativeText = "Deletions cannot be undone."
        alert.addButton(withTitle: "No")
        alert.addButton(withTitle: "Yes")
        alert.alertStyle = .warning
        
        if alert.runModal() == .alertSecondButtonReturn {
            let decoder = decoders.remove(at: tableView.selectedRow)
            decoder.delete()
                        
            tableView.removeRows(at: IndexSet(integer: tableView.selectedRow), withAnimation: .slideUp)
        }
    }
    
    @IBAction func manufacturerChanged(_ sender: NSComboBox) {
        decoderType.manufacturer = sender.stringValue
    }
    
    @IBAction func productCodeChanged(_ sender: NSTextField) {
        decoderType.productCode = sender.stringValue
    }
    
    @IBAction func productFamilyChanged(_ sender: NSComboBox) {
        decoderType.productFamily = sender.stringValue
    }
    
    @IBAction func productDescriptionChanged(_ sender: NSTextField) {
        decoderType.productDescription = sender.stringValue
    }

    @IBAction func socketChanged(_ sender: NSComboBox) {
        decoderType.socket = sender.stringValue
    }
    
    @IBAction func isProgrammableChanged(_ sender: NSButton) {
        decoderType.isProgrammable = sender.state == .on
    }
    
    @IBAction func hasSoundChanged(_ sender: NSButton) {
        decoderType.hasSound = sender.state == .on
    }
    
    @IBAction func hasRailComChanged(_ sender: NSButton) {
        decoderType.hasRailCom = sender.state == .on
    }
    
    @IBAction func minimumStockChanged(_ sender: NSTextField) {
        decoderType.minimumStock = sender.objectValue != nil ? sender.integerValue : 0
    }
    
    @IBAction func decoderSerialNumberChanged(_ sender: NSTextField) {
        guard tableView.selectedRow >= 0 else { return }
        var decoder = decoders[tableView.selectedRow]
        decoder.serialNumber = sender.stringValue
    }
    
    @IBAction func decoderFirmwareVersionChanged(_ sender: NSComboBox) {
        guard tableView.selectedRow >= 0 else { return }
        var decoder = decoders[tableView.selectedRow]
        let firmwareVersion = sender.stringValue
        decoder.firmwareVersion = firmwareVersion
        
        if !firmwareVersion.isEmpty {
            if let firmwareDate = try! decoder.firmwareDate(for: firmwareVersion) {
                decoder.firmwareDate = firmwareDate
                tableView.reloadData(forRowIndexes: IndexSet(integer: tableView.selectedRow), columnIndexes: IndexSet(integer: tableView.column(withIdentifier: .firmwareDateColumn)))
            }
        }
    }
    
    @IBAction func decoderFirmwareDateChanged(_ sender: NSTextField) {
        guard tableView.selectedRow >= 0 else { return }
        var decoder = decoders[tableView.selectedRow]
        decoder.firmwareDate = sender.objectValue as? Date
    }
    
    @IBAction func decoderAddressChanged(_ sender: NSTextField) {
        guard tableView.selectedRow >= 0 else { return }
        var decoder = decoders[tableView.selectedRow]
        decoder.address = sender.objectValue != nil ? sender.integerValue : 0
    }
    
    @IBAction func decoderSoundAuthorChanged(_ sender: NSComboBox) {
        guard tableView.selectedRow >= 0 else { return }
        var decoder = decoders[tableView.selectedRow]
        decoder.soundAuthor = sender.stringValue
    }

    @IBAction func decoderSoundProjectChanged(_ sender: NSTextField) {
        guard tableView.selectedRow >= 0 else { return }
        var decoder = decoders[tableView.selectedRow]
        decoder.soundProject = sender.stringValue
    }
    
}
    
class RetainingCellView : NSTableCellView {
    
    var dataSource: NSComboBoxDataSource?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dataSource = nil
    }
    
}

extension DecoderTypeViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return decoders?.count ?? 0
    }
    
}

extension DecoderTypeViewController : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else { return nil }
        let decoder = decoders[row]
        
        switch columnIdentifier {
        case .serialNumberColumn:
            let view = tableView.makeView(withIdentifier: .serialNumberCell, owner: self) as! NSTableCellView
            view.textField?.stringValue = decoder.serialNumber
            return view
        case .firmwareVersionColumn:
            let view = tableView.makeView(withIdentifier: .firmwareVersionCell, owner: self) as! RetainingCellView
            view.textField?.stringValue = decoder.firmwareVersion
            view.dataSource = try? SimpleComboBoxDataSource(using: decoder.sortedValuesForFirmwareVersion)
            (view.textField as? NSComboBox)?.dataSource = view.dataSource
            return view
        case .firmwareDateColumn:
            let view = tableView.makeView(withIdentifier: .firmwareDateCell, owner: self) as! NSTableCellView
            view.textField?.objectValue = decoder.firmwareDate
            (view.textField?.formatter as? DateFormatter)?.timeZone = TimeZone(secondsFromGMT: 0)
            return view
        case .addressColumn:
            let view = tableView.makeView(withIdentifier: .addressCell, owner: self) as! NSTableCellView
            view.textField?.objectValue = decoder.address != 0 ? decoder.address : nil
            return view
        case .soundAuthorColumn:
            let view = tableView.makeView(withIdentifier: .soundAuthorCell, owner: self) as! RetainingCellView
            view.textField?.stringValue = decoder.soundAuthor
            view.dataSource = try? SimpleComboBoxDataSource(using: decoder.sortedValuesForSoundAuthor)
            (view.textField as? NSComboBox)?.dataSource = view.dataSource
            return view
        case .soundProjectColumn:
            let view = tableView.makeView(withIdentifier: .soundProjectCell, owner: self) as! NSTableCellView
            view.textField?.stringValue = decoder.soundProject
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        sortDecoders()
        tableView.reloadData()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        removeButton.isEnabled = tableView.selectedRow >= 0
    }
    
}

