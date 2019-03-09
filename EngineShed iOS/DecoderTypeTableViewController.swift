//
//  DecoderTypeTableViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class DecoderTypeTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var decoderType: DecoderType? {
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
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 4
        case 2: return 1
        case 3: return decoderType?.decoders!.count ?? 0
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeHasRailCom", for: indexPath) as! DecoderTypeHasRailComTableViewCell
                cell.decoderType = decoderType
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeHasSound", for: indexPath) as! DecoderTypeHasSoundTableViewCell
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
//            cell.decoder = decoderType?.decoders![indexPath.row] as? Decoder
            return cell
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "decoderTypeDecoder" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let trainMember = train?.members![indexPath.row] as! TrainMember?

            let viewController = segue.destination as! TrainMemberTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.trainMember = trainMember
        } else*/ if segue.identifier == "decoderTypeEdit" {
            guard let decoderType = decoderType else { return }
            let navigationController = segue.destination as! UINavigationController

            let viewController = navigationController.topViewController! as! DecoderTypeEditTableViewController
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
        }
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        guard let userInfo = notification.userInfo else { return }
        guard let decoderType = decoderType else { return }

        // Check for a refresh of our decoder type object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(decoderType)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our decoder type object.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(decoderType)
        {
            self.decoderType = nil
        }
    }

}
