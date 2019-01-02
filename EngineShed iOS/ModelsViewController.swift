//
//  ModelsViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/12/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class ModelsViewController : UITableViewController, NSFetchedResultsControllerDelegate {

    weak var modelViewController: ModelViewController? = nil

    var managedObjectContext: NSManagedObjectContext?
    var classification: ModelClassification?
    var grouping: ModelGrouping = .modelClass

    var fetchRequest: NSFetchRequest<Model>?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let splitViewController = splitViewController,
            let navigationController = splitViewController.viewControllers.last as? UINavigationController
        {
            modelViewController = navigationController.topViewController as? ModelViewController
        }

        if fetchRequest == nil {
            fetchRequest = Model.fetchRequestForModels(classification: classification, groupBy: grouping)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelCell", for: indexPath) as! ModelCell
        let model = fetchedResultsController.object(at: indexPath)
        cell.withModelClass = grouping != .modelClass
        cell.model = model
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch grouping {
        case .era:
            let model = fetchedResultsController.sections?[section].objects?.first as? Model
            return model?.era?.description
        default:
            return fetchedResultsController.sections?[section].name
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "model" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let model = fetchedResultsController.object(at: indexPath)

            let viewController = (segue.destination as! UINavigationController).topViewController as! ModelViewController
            viewController.managedObjectContext = managedObjectContext
            viewController.model = model
            viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Actions

    @IBAction func groupChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: grouping = .modelClass
        case 1: grouping = .era
        case 2: grouping = .livery
        default: return
        }

        _fetchedResultsController = nil
        fetchRequest = Model.fetchRequestForModels(classification: classification, groupBy: grouping)
        tableView.reloadData()
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Model> {
        if let fetchedResultsController = _fetchedResultsController {
            return fetchedResultsController
        }
        
        guard let fetchRequest = fetchRequest, let managedObjectContext = managedObjectContext
            else { fatalError("Cannot construct controller without fetchRequest and context") }

        let sectionNameKeyPath = fetchRequest.sortDescriptors?.first?.key
        let cacheName = classification.flatMap { "ModelTable.\($0).\(grouping)" } ?? "ModelTable.all.\(grouping)"

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
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

    var _fetchedResultsController: NSFetchedResultsController<Model>? = nil

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
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? ModelCell {
                cell.withModelClass = grouping != .modelClass
                cell.model = anObject as? Model
            }
        case .move:
            if let cell = tableView.cellForRow(at: indexPath!) as? ModelCell {
                cell.withModelClass = grouping != .modelClass
                cell.model = anObject as? Model
            }
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
