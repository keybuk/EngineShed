//
//  TrainTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class TrainTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var train: Train?
    
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return trainMembers.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainName", for: indexPath) as! TrainNameTableViewCell
                cell.train = train
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainDetails", for: indexPath) as! TrainDetailsTableViewCell
                cell.train = train
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainNotes", for: indexPath) as! TrainNotesTableViewCell
                cell.train = train
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "trainMember", for: indexPath) as! TrainMemberTableViewCell
            cell.trainMember = trainMembers[indexPath.row]
            return cell
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Members"
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

    // MARK: - Train Members table

    lazy var trainMembers: [TrainMember] = {
        let fetchRequest = train?.fetchRequestForMembers()
        let trainMembers = persistentContainer?.viewContext.performAndWait { () -> [TrainMember]? in
            do {
                return try fetchRequest?.execute()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

        return trainMembers ?? []
    }()

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == persistentContainer?.viewContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let train = train else { return }

        // Check for refreshes of our train object, or its children members, meaning they
        // were updated by sync from cloud or merge after save from other context. Reload the
        // table for either case.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(train) ||
                !refreshedObjects.isDisjoint(with: trainMembers)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our train object.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(train)
        {
            self.train = nil
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainMember" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let trainMember = trainMembers[indexPath.row]

            let viewController = segue.destination as! TrainMemberTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.trainMember = trainMember
        } else if segue.identifier == "trainEdit" {
            guard let train = train else { return }
            
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController! as! TrainEditTableViewController
            
            navigationController.presentationController?.delegate = viewController
            viewController.persistentContainer = persistentContainer
            viewController.editTrain(train) { result in
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
