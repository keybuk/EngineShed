//
//  DecoderTypeTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class DecoderTypeTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var decoderType: DecoderType?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // Watch for changes that occur as a result of changes outside the view, and sync from the
        // cloud, including when the view is disappeared inside a navigation stack.
        assert(persistentContainer?.viewContext != nil, "View loaded without persistent container")
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: persistentContainer?.viewContext)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 4
        case 2: return 1
        case 3: return decoders.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return nil
        case 3: return "Decoders"
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeManufacturer", for: indexPath) as! DecoderTypeManufacturerTableViewCell
                cell.decoderType = decoderType
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeProductCode", for: indexPath) as! DecoderTypeProductCodeTableViewCell
                cell.decoderType = decoderType
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeProductFamily", for: indexPath) as! DecoderTypeProductFamilyTableViewCell
                cell.decoderType = decoderType
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeProductDescription", for: indexPath) as! DecoderTypeProductDescriptionTableViewCell
                cell.decoderType = decoderType
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeSocket", for: indexPath) as! DecoderTypeSocketTableViewCell
                cell.decoderType = decoderType
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeIsProgrammable", for: indexPath) as! DecoderTypeIsProgrammableTableViewCell
                cell.decoderType = decoderType
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeIsRailComSupported", for: indexPath) as! DecoderTypeIsRailComSupportedTableViewCell
                cell.decoderType = decoderType
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeIsSoundSupported", for: indexPath) as! DecoderTypeIsSoundSupportedTableViewCell
                cell.decoderType = decoderType
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeMinimumStock", for: indexPath) as! DecoderTypeMinimumStockTableViewCell
                cell.decoderType = decoderType
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeDecoder", for: indexPath) as! DecoderTypeDecoderTableViewCell
            cell.decoder = decoders[indexPath.row]
            return cell
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    // MARK: - Decoders table

    lazy var decoders: [Decoder] = {
        let fetchRequest = decoderType?.fetchRequestForDecoders()
        let decoders = persistentContainer?.viewContext.performAndWait { () -> [Decoder]? in
            do {
                return try fetchRequest?.execute()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

        return decoders ?? []
    }()

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == persistentContainer?.viewContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let decoderType = decoderType else { return }

        // Check for refreshes of our decoder type object, or its children decoders, meaning they
        // were updated by sync from cloud or merge after save from other context. Requery the
        // set of decoders, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(decoderType) ||
                !refreshedObjects.isDisjoint(with: decoders)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our decoder type object. We don't need to check for children
        // because deletion of those update our object's `decoders` set.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(decoderType)
        {
            self.decoderType = nil
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "decoderTypeDecoder" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let decoder = decoders[indexPath.row]

            let viewController = segue.destination as! DecoderTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.decoder = decoder
        } else if segue.identifier == "decoderTypeEdit" {
            guard let decoderType = decoderType else { return }

            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController! as! DecoderTypeEditTableViewController

            navigationController.presentationController?.delegate = viewController
            viewController.persistentContainer = persistentContainer
            viewController.editDecoderType(decoderType) { result in
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
        } else if segue.identifier == "decoderTypeDecoderAdd" {
            guard let decoderType = decoderType else { return }

            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! DecoderEditTableViewController

            navigationController.presentationController?.delegate = viewController
            viewController.persistentContainer = persistentContainer
            viewController.addDecoder(type: decoderType) { result in
                if case .saved(let decoder) = result,
                    let index = self.decoders.firstIndex(of: decoder)
                {
                    let indexPath = IndexPath(row: index, section: 3)
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    self.performSegue(withIdentifier: "decoderTypeDecoder", sender: nil)
                }

                self.dismiss(animated: true)
            }
        }
    }

}
