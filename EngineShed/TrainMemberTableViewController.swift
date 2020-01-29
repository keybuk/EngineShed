//
//  TrainMemberTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class TrainMemberTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var trainMember: TrainMember?

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
        case 0: return 1
        case 1: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberTitle", for: indexPath) as! TrainMemberTitleTableViewCell
                cell.trainMember = trainMember
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberIsFlipped", for: indexPath) as! TrainMemberIsFlippedTableViewCell
                cell.trainMember = trainMember
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == persistentContainer?.viewContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let trainMember = trainMember else { return }

        // Check for a refresh of our train member object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(trainMember)
        {
            tableView.reloadData()
        }

        // Check for a deletion of our train member object.
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletedObjects.contains(trainMember)
        {
            self.trainMember = nil
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainMemberEdit" {
            guard let trainMember = trainMember else { return }

            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController! as! TrainMemberEditTableViewController

            navigationController.presentationController?.delegate = viewController
            viewController.persistentContainer = persistentContainer
            viewController.editTrainMember(trainMember) { result in
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
