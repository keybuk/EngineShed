//
//  PurchaseViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

extension NSStoryboardSegue.Identifier {
    
    static let purchaseModelsSegue = "purchaseModelsSegue"
    static let modelSegue = "modelSegue"

}

class PurchaseViewController: NSViewController {
    
    @IBOutlet var manufacturerComboBox: NSComboBox!
    @IBOutlet var catalogNumberTextField: NSTextField!
    @IBOutlet var catalogYearTextField: NSTextField!
    @IBOutlet var catalogDescriptionTextField: NSTextField!
    @IBOutlet var limitedEditionTextField: NSTextField!
    @IBOutlet var limitedEditionNumberTextField: NSTextField!
    @IBOutlet var limitedEditionCountTextField: NSTextField!
    @IBOutlet var dateTextField: NSTextField!
    @IBOutlet var storeComboBox: NSComboBox!
    @IBOutlet var priceTextField: NSTextField!
    @IBOutlet var conditionComboBox: NSComboBox!
    @IBOutlet var valuationTextField: NSTextField!
    @IBOutlet var notesTextField: NSTextField!
    
    var purchaseModelsViewController: PurchaseModelsViewController!
    var modelViewController: ModelViewController!
    
    var manufacturerComboBoxDataSource: SimpleComboBoxDataSource?
    var storeComboBoxDataSource: SimpleComboBoxDataSource?
    var conditionComboBoxDataSource: EnumComboBoxDataSource?

    var purchase: Purchase!

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case .purchaseModelsSegue:
            purchaseModelsViewController = segue.destinationController as? PurchaseModelsViewController
        case .modelSegue:
            modelViewController = segue.destinationController as? ModelViewController
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard case .model(let model) = currentRecord else { return }
        
        purchase = model.purchase!
        
        reloadData()
        
        if purchase.manufacturer?.isEmpty ?? true {
            view.window?.makeFirstResponder(self.manufacturerComboBox)
        }
    }
    
    func reloadData() {
        manufacturerComboBoxDataSource = try? SimpleComboBoxDataSource(using: purchase.sortedValuesForManufacturer)
        manufacturerComboBox.dataSource = manufacturerComboBoxDataSource
        manufacturerComboBox.stringValue = purchase.manufacturer ?? ""
        
        catalogNumberTextField.stringValue = purchase.catalogNumber ?? ""
        catalogYearTextField.objectValue = purchase.catalogYear != 0 ? purchase.catalogYear : nil
        catalogDescriptionTextField.stringValue = purchase.catalogDescription ?? ""
        limitedEditionTextField.stringValue = purchase.limitedEdition ?? ""
        limitedEditionNumberTextField.objectValue = purchase.limitedEditionNumber != 0 ? purchase.limitedEditionNumber : nil
        limitedEditionCountTextField.objectValue = purchase.limitedEditionCount != 0 ? purchase.limitedEditionCount : nil
        dateTextField.objectValue = purchase.dateAsDate
        
        storeComboBoxDataSource = try? SimpleComboBoxDataSource(using: purchase.sortedValuesForStore)
        storeComboBox.dataSource = storeComboBoxDataSource
        storeComboBox.stringValue = purchase.store ?? ""
        
        priceTextField.objectValue = purchase.priceAsDecimal
        
        conditionComboBoxDataSource = EnumComboBoxDataSource(wrapping: Purchase.Condition.self)
        conditionComboBox.dataSource = conditionComboBoxDataSource
        conditionComboBox.formatter = conditionComboBoxDataSource
        conditionComboBox.objectValue = purchase.condition.map(NSArray.init(object:))
    
        valuationTextField.objectValue = purchase.valuationAsDecimal
        notesTextField.stringValue = purchase.notes ?? ""
    }
    
    func fillFromSimilar() {
        if (try? purchase.fillFromSimilar()) == true {
            try? purchase.managedObjectContext?.save() // FIXME
            reloadData()
            recordController?.currentRecord = .model(purchase.models!.array[0] as! Model)
        }
    }
    
    @IBAction func manufacturerChanged(_ sender: NSComboBox) {
        let manufacturer = sender.stringValue
        let tryFill = purchase.manufacturer != manufacturer
        purchase.manufacturer = manufacturer
        
        if tryFill {
            fillFromSimilar()
        }
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func catalogNumberChanged(_ sender: NSTextField) {
        let catalogNumber = sender.stringValue
        let tryFill = purchase.catalogNumber != catalogNumber
        purchase.catalogNumber = catalogNumber
        
        if tryFill {
            fillFromSimilar()
        }
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func catalogYearChanged(_ sender: NSTextField) {
        purchase.catalogYear = sender.objectValue != nil ? Int16(clamping: sender.integerValue) : 0
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func catalogDescriptionChanged(_ sender: NSTextField) {
        purchase.catalogDescription = sender.stringValue
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func limitedEditionChanged(_ sender: NSTextField) {
        purchase.limitedEdition = sender.stringValue
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func limitedEditionNumberChanged(_ sender: NSTextField) {
        purchase.limitedEditionNumber = sender.objectValue != nil ? Int16(clamping: sender.integerValue) : 0
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func limitedEditionCountChanged(_ sender: NSTextField) {
        purchase.limitedEditionCount = sender.objectValue != nil ? Int16(clamping: sender.integerValue) : 0
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func dateChanged(_ sender: NSTextField) {
        purchase.dateAsDate = sender.objectValue as? Date
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func storeChanged(_ sender: NSComboBox) {
        purchase.store = sender.stringValue
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func priceChanged(_ sender: NSTextField) {
        purchase.priceAsDecimal = sender.objectValue as? Decimal
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func purchaseConditionChanged(_ sender: NSComboBox) {
        purchase.condition = (sender.objectValue as? [Purchase.Condition])?.first
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func valuationChanged(_ sender: NSTextField) {
        purchase.valuationAsDecimal = sender.objectValue as? Decimal
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
    @IBAction func notesChanged(_ sender: NSTextField) {
        purchase.notes = sender.stringValue
        try? purchase.managedObjectContext?.save() // FIXME
    }
    
}
