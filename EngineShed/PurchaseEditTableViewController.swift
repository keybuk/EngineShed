//
//  PurchaseEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class PurchaseEditTableViewController : UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var purchase: Purchase?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateEditingState()
    }

    // MARK: - Table view data source

    var datePickerVisible = false
    let datePickerIndexPath = IndexPath(row: 1, section: 2)

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
                tableView.deselectRow(at: indexPath, animated: true)

                if !datePickerVisible {
                    datePickerVisible = true

                    tableView.insertRows(at: [datePickerIndexPath], with: .top)
                    tableView.scrollToRow(at: datePickerIndexPath, at: .middle, animated: true)

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

                                self.tableView.deleteRows(at: [self.datePickerIndexPath], with: .top)
                                dateEditCell?.pickerVisible = self.datePickerVisible
                            }
                        }
                    }
                } else {
                    datePickerVisible = false

                    tableView.deleteRows(at: [datePickerIndexPath], with: .top)
                    dateEditCell?.pickerVisible = datePickerVisible
                }

            default: break
            }
        case 3: break
        case 4: confirmDeletePurchase(from: indexPath)
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        // Default handling
        if let cell = tableView.cellForRow(at: indexPath),
            cell.canBecomeFirstResponder
        {
            cell.becomeFirstResponder()
        }
    }

    // MARK: - Presentation Delegate

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmDiscardChanges()
    }

    // MARK: - Presenter API

    func editPurchase(_ purchase: Purchase, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        self.purchase = managedObjectContext!.object(with: purchase.objectID) as? Purchase
    }

    func addPurchase(completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        purchase = Purchase(context: managedObjectContext!)
    }
    
    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let purchase = purchase else { return }

        // Update editing state whenever our purchase object is updated.
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updatedObjects.contains(purchase)
        {
            updateEditingState()
        }

        // Check for a refresh of our purchase object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(purchase)
        {
            tableView.reloadData()
        }
    }

    // MARK: - Commit methods
    
    enum Result {
        case canceled
        case saved(Purchase)
        case deleted
    }
    
    private var completionHandler: ((Result) -> Void)!

    func hasChanges() -> Bool {
        guard let purchase = purchase else { return false }

        return purchase.hasChanges
    }
    
    func isValid() -> Bool {
        guard let purchase = purchase else { return false }
        
        do {
            if purchase.isInserted {
                try purchase.validateForInsert()
            } else if purchase.isUpdated {
                try purchase.validateForUpdate()
            }
            
            return true
        } catch {
            return false
        }
    }
    
    func updateEditingState() {
        // Disable interaction and pull-to-dismiss when there are pending changes.
        isModalInPresentation = hasChanges()
        
        // Enable the save button only if there has been a change, and that the result is valid.
        saveButton.isEnabled = hasChanges() && isValid()
    }

    func confirmDiscardChanges() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if isValid() {
            alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
                self.savePurchase()
            })
        }

        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.discardChanges()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Set iPad presentation.
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = cancelButton
        }

        present(alert, animated: true)
    }

    func discardChanges() {
        completionHandler?(.canceled)
    }

    func savePurchase() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let purchase = purchase else { return }

        do {
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }

            // Give the view context a chance to receive the merge notification before grabbing
            // a copy of the object and running the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                let purchase = viewContext.object(with: purchase.objectID) as! Purchase
                self.completionHandler?(.saved(purchase))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func confirmDeletePurchase(from indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Purchase", style: .destructive) { _ in
            self.deletePurchase()
        })
        
        // Cancel case, deselect the table row.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
        
        // Set iPad presentation.
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: indexPath)
        }
        
        present(alert, animated: true)
    }
    
    func deletePurchase() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let purchase = purchase else { return }
        
        do {
            managedObjectContext.delete(purchase)
            try managedObjectContext.save()
            
            // Give the view context a chance to receive the merge notification before running
            // the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                self.completionHandler?(.deleted)
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }    

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        discardChanges()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        savePurchase()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "purchaseConditionPicker" {
            let viewController = segue.destination as! PurchaseConditionPickerTableViewController
            viewController.purchase = purchase
        }
    }

}
