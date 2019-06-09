//
//  PurchaseViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

protocol PurchaseSettable : class {

    var purchase: Purchase? { get set }

}

class PurchaseTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var purchase: Purchase? {
        didSet {
            // Update the view.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // Register for notifications of changes to the view context so we can update the view
        // when changes to the record are merged back into it.
        if let managedObjectContext = persistentContainer?.viewContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 11
        case 1: return purchase?.models!.count ?? 0
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        switch (indexPath.section, indexPath.row) {
        case (0, 0): identifier = "purchaseManufacturer"
        case (0, 1): identifier = "purchaseCatalogNumber"
        case (0, 2): identifier = "purchaseCatalogDescription"
        case (0, 3): identifier = "purchaseCatalogYear"
        case (0, 4): identifier = "purchaseLimitedEdition"
        case (0, 5): identifier = "purchaseDate"
        case (0, 6): identifier = "purchaseStore"
        case (0, 7): identifier = "purchasePrice"
        case (0, 8): identifier = "purchaseCondition"
        case (0, 9): identifier = "purchaseValuation"
        case (0, 10): identifier = "purchaseNotes"
        case (1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseModel", for: indexPath) as! PurchaseModelTableViewCell
            let model = purchase?.models![indexPath.row] as! Model?
            cell.model = model
            return cell
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UITableViewCell & PurchaseSettable
        cell.purchase = purchase
        return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "purchaseModel" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let model = purchase?.models![indexPath.row] as! Model?

            let viewController = segue.destination as! ModelTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.model = model
        } else if segue.identifier == "purchaseEdit" {
            guard let purchase = purchase else { return }
            let navigationController = segue.destination as! UINavigationController

            let viewController = navigationController.topViewController! as! PurchaseEditTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.editPurchase(purchase) { result in
                if case .deleted = result {
                    // When we pop ourselves off the stack, we lose the link to the presented modal
                    // controller, so stash that for now. This allows us to animate the modal going
                    // away to something other than the view we're currently deleting.
                    let realPresentingViewController = self.presentedViewController?.presentingViewController
                    self.navigationController?.popDetailViewController(animated: false)
                    realPresentingViewController?.dismiss(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }
        } else if segue.identifier == "purchaseModelAdd" {
            guard let purchase = purchase else { return }
            let navigationController = segue.destination as! UINavigationController

            let viewController = navigationController.topViewController as! ModelEditTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.addModel(to: purchase) { result in
                if case .saved(let model) = result {
                    let index = purchase.models!.index(of: model)
                    if index != NSNotFound {
                        let indexPath = IndexPath(row: index, section: 1)
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                        self.performSegue(withIdentifier: "purchaseModel", sender: nil)
                    }
                }

                self.dismiss(animated: true)
            }
        }
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        guard let userInfo = notification.userInfo else { return }
        guard let purchase = purchase else { return }

        // Check for refreshes of our purchase object, or its children models, meaning they
        // were updated by sync from cloud or merge after save from other context.
        // Reload the table in either case.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(purchase) ||
                !refreshedObjects.isDisjoint(with: purchase.models!.set as! Set<NSManagedObject>)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our purchase object.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(purchase)
        {
            self.purchase = nil
        }
    }

}
