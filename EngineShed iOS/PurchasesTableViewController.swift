//
//  PurchasesTableViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class PurchasesTableViewController : UITableViewController, NSFetchedResultsControllerDelegate {

    var persistentContainer: NSPersistentContainer?

    var ordering: PurchaseOrdering = .date
    var fetchRequest: NSFetchRequest<Purchase>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        if fetchRequest == nil {
            fetchRequest = Purchase.fetchRequestForPurchases(orderingBy: ordering)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let splitViewController = splitViewController {
            clearsSelectionOnViewWillAppear = splitViewController.isCollapsed
        }

        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchase", for: indexPath) as! PurchaseTableViewCell
        let purchase = fetchedResultsController.object(at: indexPath)
        cell.ordering = ordering
        cell.purchase = purchase
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch ordering {
        case .date:
            let purchase = fetchedResultsController.sections?[section].objects?.first as? Purchase
            return purchase?.dateForGroupingAsString ?? "Unknown"
        default:
            return fetchedResultsController.sections?[section].name
        }
    }

    // MARK: - Navigation

    var addedPurchase: Purchase?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "purchase" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let purchase = fetchedResultsController.object(at: indexPath)

            let viewController = (segue.destination as! UINavigationController).topViewController as! PurchaseTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.purchase = purchase
            viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "purchaseAdd" {
            let navigationController = segue.destination as! UINavigationController

            let viewController = navigationController.topViewController as! PurchaseEditTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.addPurchase() { purchase in
                self.addedPurchase = purchase
                self.performSegue(withIdentifier: "purchaseAdded", sender: nil)
            }
        } else if segue.identifier == "purchaseAdded" {
            guard let purchase = addedPurchase else { return }
            addedPurchase = nil

            let navigationController = segue.destination as! UINavigationController

            let viewController = navigationController.topViewController as! PurchaseTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.purchase = purchase
        }
    }

    // MARK: - Actions

    @IBAction func groupChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: ordering = .date
        case 1: ordering = .catalog
        default: return
        }

        _fetchedResultsController = nil
        fetchRequest = Purchase.fetchRequestForPurchases(orderingBy: ordering)
        tableView.reloadData()
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Purchase> {
        if let fetchedResultsController = _fetchedResultsController {
            return fetchedResultsController
        }

        guard let managedObjectContext = persistentContainer?.viewContext, let fetchRequest = fetchRequest
            else { preconditionFailure("Cannot construct controller without fetchRequest and context") }

        let sectionNameKeyPath = fetchRequest.sortDescriptors?.first?.key
//        let cacheName = "PurchasesViewController.\(ordering)"

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil /*cacheName*/)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        _fetchedResultsController = fetchedResultsController
        return fetchedResultsController
    }

    var _fetchedResultsController: NSFetchedResultsController<Purchase>? = nil

    // MARK: NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            assertionFailure("Unimplemented fetched results controller change type: \(type)")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? PurchaseTableViewCell {
                cell.ordering = ordering
                cell.purchase = anObject as? Purchase
            }
        case .move:
            if let cell = tableView.cellForRow(at: indexPath!) as? PurchaseTableViewCell {
                cell.ordering = ordering
                cell.purchase = anObject as? Purchase
            }
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            assertionFailure("Unimplemented fetched results controller change type: \(type)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
