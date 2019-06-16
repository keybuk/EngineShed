//
//  DecoderTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class DecoderTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var decoder: Decoder?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // Watch for changes that occur as a result of changes outside the view, and sync from the
        // cloud, including when the view is disappeared inside a navigation stack.
        guard let managedObjectContext = persistentContainer?.viewContext else { preconditionFailure("View loaded without persistent container") }
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 4
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSerialNumber", for: indexPath) as! DecoderSerialNumberTableViewCell
                cell.decoder = decoder
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderAddress", for: indexPath) as! DecoderAddressTableViewCell
                cell.decoder = decoder
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderFirmwareVersion", for: indexPath) as! DecoderFirmwareVersionTableViewCell
                cell.decoder = decoder
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderFirmwareDate", for: indexPath) as! DecoderFirmwareDateTableViewCell
                cell.decoder = decoder
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundAuthor", for: indexPath) as! DecoderSoundAuthorTableViewCell
                cell.decoder = decoder
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundProject", for: indexPath) as! DecoderSoundProjectTableViewCell
                cell.decoder = decoder
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundProjectVersion", for: indexPath) as! DecoderSoundProjectVersionTableViewCell
                cell.decoder = decoder
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundSettings", for: indexPath) as! DecoderSoundSettingsTableViewCell
                cell.decoder = decoder
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
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

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == persistentContainer?.viewContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let decoder = decoder else { return }

        // Check for a refresh of our decoder object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(decoder)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our decoder object.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(decoder)
        {
            self.decoder = nil
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "decoderEdit" {
            guard let decoder = decoder else { return }

            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController! as! DecoderEditTableViewController

            navigationController.presentationController?.delegate = viewController
            viewController.persistentContainer = persistentContainer
            viewController.editDecoder(decoder) { result in
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

}
