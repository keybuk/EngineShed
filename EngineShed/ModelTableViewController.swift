//
//  ModelTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

protocol ModelSettable : class {

    var model: Model? { get set }

}

class ModelTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var model: Model?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // Watch for changes that occur as a result of changes outside the view, and sync from the
        // cloud, including when the view is disappeared inside a navigation stack.
//        assert(persistentContainer?.viewContext != nil, "View loaded without persistent container")
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: persistentContainer?.viewContext)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 12
        case 1: return 2
        case 2: return 12
        case 3: return 5
        case 4: return 3
        case 5: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        switch (indexPath.section, indexPath.row) {
        case (0, 0): identifier = "modelImage"
        case (0, 1): identifier = "modelPurchase"
        case (0, 2): identifier = "modelClassification"
        case (0, 3): identifier = "modelClass"
        case (0, 4): identifier = "modelWheelArrangement"
        case (0, 5): identifier = "modelNumber"
        case (0, 6): identifier = "modelName"
        case (0, 7): identifier = "modelLivery"
        case (0, 8): identifier = "modelDetails"
        case (0, 9): identifier = "modelEra"
        case (0, 10): identifier = "modelGauge"
        case (0, 11): identifier = "modelDisposition"
        // Electrical
        case (1, 0): identifier = "modelMotor"
        case (1, 1): identifier = "modelLights"
        // DCC
        case (2, 0): identifier = "modelSocket"
        case (2, 1): identifier = "modelDecoderType"
        case (2, 2): identifier = "modelDecoderSerialNumber"
        case (2, 3): identifier = "modelDecoderFirmwareVersion"
        case (2, 4): identifier = "modelDecoderFirmwareDate"
        case (2, 5): identifier = "modelDecoderAddress"
        case (2, 6): identifier = "modelDecoderSoundAuthor"
        case (2, 7): identifier = "modelDecoderSoundProject"
        case (2, 8): identifier = "modelDecoderSoundProjectVersion"
        case (2, 9): identifier = "modelDecoderSoundSettings"
        case (2, 10): identifier = "modelSpeaker"
        case (2, 11): identifier = "modelSpeakerFittings"
        // Details
        case (3, 0): identifier = "modelCouplings"
        case (3, 1): identifier = "modelFeatures"
        case (3, 2): identifier = "modelDetailParts"
        case (3, 3): identifier = "modelFittedDetailParts"
        case (3, 4): identifier = "modelModifications"
        // Maintenance
        case (4, 0): identifier = "modelLastRun"
        case (4, 1): identifier = "modelLastOil"
        case (4, 2): identifier = "modelTasks"
        // Notes
        case (5, 0): identifier = "modelNotes"

        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UITableViewCell & ModelSettable
        cell.model = model
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Electrical"
        case 2: return "DCC"
        case 3: return "Details"
        case 4: return "Maintenance"
        case 5: return "Notes"
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

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == persistentContainer?.viewContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let model = model else { return }

        // Check for a refresh of our model object, or linked purchase or decoder objects, by sync
        // from cloud or merge after save from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(model) ||
                (model.purchase.map({ refreshedObjects.contains($0) }) ?? false) ||
                (model.decoder.map({ refreshedObjects.contains($0) }) ?? false) ||
                (model.trainMember.map({ refreshedObjects.contains($0) }) ?? false)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our model object,.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(model)
        {
            self.model = nil
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelPurchase" {
            let viewController = segue.destination as! PurchaseTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.purchase = model?.purchase
        } else if segue.identifier == "modelEdit" {
            guard let model = model else { return }

            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController! as! ModelEditTableViewController

            navigationController.presentationController?.delegate = viewController
            viewController.persistentContainer = persistentContainer
            viewController.editModel(model) { result in
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
