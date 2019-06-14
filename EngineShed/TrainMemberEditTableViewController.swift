//
//  TrainMemberEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class TrainMemberEditTableViewController: UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var trainMember: TrainMember?

    enum Result {
        case canceled
        case saved(TrainMember)
        case deleted
    }

    private var completionHandler: ((Result) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // Set the initial save button state.
        updateSaveButton()

        // Register for notifications of changes to our background context so we can update the
        // field values when changed outside this view.
        if let managedObjectContext = managedObjectContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (trainMember?.isInserted ?? true) ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberTitleEdit", for: indexPath) as! TrainMemberTitleEditTableViewCell
                cell.trainMember = trainMember
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberIsFlippedEdit", for: indexPath) as! TrainMemberIsFlippedEditTableViewCell
                cell.trainMember = trainMember
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            precondition(!(trainMember?.isInserted ?? true), "Unexpected delete train member section in inserted train member")
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberDelete", for: indexPath) as! TrainMemberDeleteTableViewCell
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1: break
        case 2:
            precondition(!(trainMember?.isInserted ?? true), "Unexpected delete train member section in inserted train member")

            // Confirm train deletion using an alert.
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete Train Member", style: .destructive) { action in
                self.deleteTrainMember()
            })

            // Cancel case, deselect the table row.
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })

            // Set iPad presentation.
            if let popover = alert.popoverPresentationController {
                popover.sourceView = tableView;
                popover.sourceRect = tableView.rectForRow(at: indexPath)
            }

            present(alert, animated: true)
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        // Default handling
        if let cell = tableView.cellForRow(at: indexPath),
            cell.canBecomeFirstResponder
        {
            cell.becomeFirstResponder()
        }
    }

    // MARK: - Object management and observation

    func editTrainMember(_ trainMember: TrainMember, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext!.performAndWait {
            self.trainMember = managedObjectContext!.object(with: trainMember.objectID) as? TrainMember

            // Use KVO to keep the save button state up to date.
            self.observeTrainMember()
        }
    }

    func addTrainMember(completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext!.performAndWait {
            self.trainMember = TrainMember(context: managedObjectContext!)

            // Use KVO to keep the save button state up to date.
            self.observeTrainMember()
        }
    }

    var observers: [NSKeyValueObservation] = []

    func observeTrainMember() {
        observers.removeAll()
        guard let trainMember = trainMember else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(trainMember.observe(\.title) { (_, _) in self.updateSaveButton() })
        observers.append(trainMember.observe(\.isFlipped) { (_, _) in self.updateSaveButton() })
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let trainMember = trainMember else { return }

        // Check for a refresh of our train member object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(trainMember)
        {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.completionHandler?(.canceled)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let trainMember = trainMember else { return }

        do {
            try managedObjectContext.performAndWait {
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
            }

            // Give the view context a chance to receive the merge notification before grabbing
            // a copy of the object and running the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                let trainMember = viewContext.object(with: trainMember.objectID) as! TrainMember
                self.completionHandler?(.saved(trainMember))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func deleteTrainMember() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let trainMember = trainMember else { return }

        do {
            try managedObjectContext.performAndWait {
                managedObjectContext.delete(trainMember)

                try managedObjectContext.save()
            }

            // Give the view context a chance to receive the merge notification before running
            // the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                self.completionHandler?(.deleted)
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func updateSaveButton() {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let trainMember = trainMember else { return }

        // Enable the save button only if there has been a change, and that the result is valid.
        saveButton.isEnabled = managedObjectContext.performAndWait {
            var isChanged = false

            do {
                if trainMember.isInserted {
                    try trainMember.validateForInsert()
                    isChanged = true
                } else if trainMember.isUpdated {
                    try trainMember.validateForUpdate()
                    isChanged = true
                }

                return isChanged
            } catch {
                return false
            }
        }
    }

}
