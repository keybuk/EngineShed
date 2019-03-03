//
//  PurchaseEditTableViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class PurchaseEditTableViewController : UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var purchase: Purchase?
    private var completionHandler: ((Purchase) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view to editing so rows can be reordered and one-tap deleted, and also to show
        // the insert accessory.
//        isEditing = true

        // Set the initial save button state.
        updateSaveButton()

        // Register for notifications of changes to our background context so we can update the
        // field values when changed outside this view.
        if let managedObjectContext = managedObjectContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    // MARK: - Table view data source

    var datePickerVisible = false

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (purchase?.isInserted ?? true) ? 4 : 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 3
        case 2: return 5 + (datePickerVisible ? 1 : 0)
        case 3: return 1
        case 4: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseManufacturerEdit", for: indexPath) as! PurchaseManufacturerEditTableViewCell
                cell.purchase = purchase
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCatalogNumberEdit", for: indexPath) as! PurchaseCatalogNumberEditTableViewCell
                cell.purchase = purchase
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCatalogDescriptionEdit", for: indexPath) as! PurchaseCatalogDescriptionEditTableViewCell
                cell.purchase = purchase
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCatalogYearEdit", for: indexPath) as! PurchaseCatalogYearEditTableViewCell
                cell.purchase = purchase
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseLimitedEditionEdit", for: indexPath) as! PurchaseLimitedEditionEditTableViewCell
                cell.purchase = purchase
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseLimitedEditionNumberEdit", for: indexPath) as! PurchaseLimitedEditionNumberEditTableViewCell
                cell.purchase = purchase
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseLimitedEditionCountEdit", for: indexPath) as! PurchaseLimitedEditionCountEditTableViewCell
                cell.purchase = purchase
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            let datePickerOffset = datePickerVisible ? 1 : 0
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseDateEdit", for: indexPath) as! PurchaseDateEditTableViewCell
                cell.purchase = purchase
                cell.pickerVisible = datePickerVisible
                return cell
            case 1 where datePickerVisible:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseDatePicker", for: indexPath) as! PurchaseDatePickerTableViewCell
                cell.purchase = purchase
                return cell
            case 1 + datePickerOffset:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseStoreEdit", for: indexPath) as! PurchaseStoreEditTableViewCell
                cell.purchase = purchase
                return cell
            case 2 + datePickerOffset:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchasePriceEdit", for: indexPath) as! PurchasePriceEditTableViewCell
                cell.purchase = purchase
                return cell
            case 3 + datePickerOffset:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseConditionEdit", for: indexPath) as! PurchaseConditionEditTableViewCell
                cell.purchase = purchase
                return cell
            case 4 + datePickerOffset:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseValuationEdit", for: indexPath) as! PurchaseValuationEditTableViewCell
                cell.purchase = purchase
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseNotesEdit", for: indexPath) as! PurchaseNotesEditTableViewCell
                cell.purchase = purchase
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 4:
            precondition(!(purchase?.isInserted ?? true), "Unexpected delete purchase section in inserted purchase")
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseDelete", for: indexPath) as! PurchaseDeleteTableViewCell
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }

        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Catalog"
        case 1: return "Limited Edition"
        case 2: return "Purchase"
        case 3: return "Notes"
        case 4: return nil
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1: break
        case 2:
            switch indexPath.row {
            case 0:
                weak var dateEditCell = tableView.cellForRow(at: indexPath) as? PurchaseDateEditTableViewCell

                let datePickerIndexPath = IndexPath(row: 1, section: 2)
                if !datePickerVisible {
                    datePickerVisible = true
                    tableView.insertRows(at: [datePickerIndexPath], with: .top)
//                    tableView.scrollToRow(at: datePickerIndexPath, at: .bottom, animated: true)

                    dateEditCell?.pickerVisible = datePickerVisible

                    // Make the date picker the first responder, and when it loses that status,
                    // hide the cell again.
                    if let cell = tableView.cellForRow(at: datePickerIndexPath) as? PurchaseDatePickerTableViewCell,
                        cell.canBecomeFirstResponder,
                        cell.becomeFirstResponder()
                    {
                        cell.resignFirstResponderBlock = {
                            if self.datePickerVisible {
                                self.datePickerVisible = false
                                self.tableView.deleteRows(at: [datePickerIndexPath], with: .top)

                                dateEditCell?.pickerVisible = self.datePickerVisible
                            }
                        }
                    }
                } else {
                    datePickerVisible = false
                    tableView.deleteRows(at: [datePickerIndexPath], with: .top)

                    dateEditCell?.pickerVisible = datePickerVisible
                }

                tableView.deselectRow(at: indexPath, animated: true)
            default: break
            }
        case 3: break
        case 4:
            precondition(!(purchase?.isInserted ?? true), "Unexpected purchase train section in inserted purchase")

            // Confirm train deletion using an alert.
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete Purchase", style: .destructive) { action in
                self.deletePurchase()
            })

            // Cancel case, deselect the table row.
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })

            present(alert, animated: true)
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        // Default handling
        if let cell = tableView.cellForRow(at: indexPath),
            cell.canBecomeFirstResponder
        {
            cell.becomeFirstResponder()
        }
    }

    // MARK: - Object management and observation

    func editPurchase(_ purchase: Purchase) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        // Merge from the store, but keep any local changes.
        managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext!.performAndWait {
            self.purchase = managedObjectContext!.object(with: purchase.objectID) as? Purchase

            // Use KVO to keep the save button state up to date.
            self.observePurchase()
        }
    }

    func addPurchase(completionHandler: ((Purchase) -> Void)? = nil) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Merge from the store, but keep any local changes.
        managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext!.performAndWait {
            self.purchase = Purchase(context: managedObjectContext!)

            // Use KVO to keep the save button state up to date.
            self.observePurchase()
        }
    }

    var observers: [NSKeyValueObservation] = []

    func observePurchase() {
        self.observers.removeAll()
        guard let purchase = purchase else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        self.observers.append(purchase.observe(\.manufacturer) { (_, _) in self.updateSaveButton() })
        self.observers.append(purchase.observe(\.catalogNumber) { (_, _) in self.updateSaveButton() })
        self.observers.append(purchase.observe(\.catalogDescription) { (_, _) in self.updateSaveButton() })
        // FIXME: more
        self.observers.append(purchase.observe(\.models) { (_, _) in
            self.updateSaveButton()
            self.observePurchaseModels()
        })

        self.observePurchaseModels()
    }

    var modelObservers: [NSKeyValueObservation] = []

    func observePurchaseModels() {
        self.modelObservers.removeAll()
        guard let purchase = purchase else { return }
        guard let models = purchase.models else { return }

        for case let model as Model in models {
            self.observers.append(model.observe(\.modelClass) { (_, _) in self.updateSaveButton() })
        }
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let purchase = purchase else { return }

        // Check for a refresh of our purchase object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(purchase)
        {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let purchase = purchase else { return }

        do {
            try managedObjectContext.performAndWait {
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
            }

            persistentContainer?.viewContext.performAndWait {
                let purchase = persistentContainer!.viewContext.object(with: purchase.objectID) as! Purchase
                self.completionHandler?(purchase)
                self.dismiss(animated: true)
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func deletePurchase() {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let purchase = purchase else { return }

        do {
            try managedObjectContext.performAndWait {
                managedObjectContext.delete(purchase)

                try managedObjectContext.save()
            }

            self.dismiss(animated: true)
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func updateSaveButton() {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let purchase = purchase else { return }

        // Enable the save button only if there has been a change, and that the result is valid.
        saveButton.isEnabled = managedObjectContext.performAndWait {
            var isChanged = false

            do {
                if purchase.isInserted {
                    try purchase.validateForInsert()
                    isChanged = true
                } else if purchase.isUpdated {
                    try purchase.validateForUpdate()
                    isChanged = true
                }

                guard let models = purchase.models else { return isChanged }
                for case let model as Model in models {
                    if model.isInserted {
                        try model.validateForInsert()
                        isChanged = true
                    } else if model.isUpdated {
                        try model.validateForUpdate()
                        isChanged = true
                    }
                }

                return isChanged
            } catch {
                return false
            }
        }
    }
}
