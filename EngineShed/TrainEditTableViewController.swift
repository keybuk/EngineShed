//
//  TrainEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/1/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class TrainEditTableViewController : UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var train: Train?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view to editing so rows can be reordered and one-tap deleted, and also to show
        // the insert accessory.
        isEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateEditingState()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (train?.isInserted ?? true) ? 3 : 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return trainMembers.count + 1
        case 3: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainNameEdit", for: indexPath) as! TrainNameEditTableViewCell
                cell.train = train
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainDetailsEdit", for: indexPath) as! TrainDetailsEditTableViewCell
                cell.train = train
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainNotesEdit", for: indexPath) as! TrainNotesEditTableViewCell
                cell.train = train
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case ..<(train?.members!.count ?? 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberEdit", for: indexPath) as! TrainMemberEditTableViewCell
                cell.trainMember = trainMembers[indexPath.row]
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainMemberAdd", for: indexPath) as! TrainMemberAddTableViewCell
                return cell
            }
        case 3:
            precondition(!(train?.isInserted ?? true), "Unexpected delete train section in inserted train")
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainDelete", for: indexPath) as! TrainDeleteTableViewCell
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return "Members"
        case 3: return nil
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1: break
        case 2:
            switch indexPath.row {
            case ..<trainMembers.count: break
            default:
                // Call the delegate method as if the insertion control was tapped directly.
                self.tableView(tableView, commit: .insert, forRowAt: indexPath)
            }
        case 3: confirmDeleteTrain(from: indexPath)
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        // Default handling
        if let cell = tableView.cellForRow(at: indexPath),
            cell.canBecomeFirstResponder
        {
            cell.becomeFirstResponder()
        }
    }

    // MARK: Editing support

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1: return false
        case 2: return true
        case 3: return false
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch indexPath.section {
        case 0: return .none
        case 1: return .none
        case 2:
            switch indexPath.row {
            case ..<trainMembers.count:
                return .delete
            default:
                return .insert
            }
        case 3: return .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let train = train else { return }

        if editingStyle == .delete {
            precondition(indexPath.section == 2, "Attempt to delete cell outside of members")
            precondition(indexPath.row < train.members!.count, "Attempt to delete non-member cell")

            // Remove the member from the list, and delete it. Both are required otherwise it
            // remains as a member without a train, or a deleted member in our relationship.
            let trainMember = trainMembers[indexPath.row]
            train.removeMember(trainMember)
            managedObjectContext.delete(trainMember)

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            precondition(indexPath.section == 2, "Attempt to insert cell outside of members")
            precondition(indexPath.row == train.members!.count, "Attempt to insert within members")

            // Insert a blank member at the end of the members list.
            let trainMember = TrainMember(context: managedObjectContext)
            train.addMember(trainMember)

            // After inserting the row, select it to trigger immediate editing.
            tableView.insertRows(at: [indexPath], with: .bottom)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }

    // MARK: Reordering support

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1: return false
        case 2:
            switch indexPath.row {
            case ..<trainMembers.count:
                return true
            default:
                return false
            }
        case 3: return false
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        precondition(sourceIndexPath.section == 2, "Attempt to move cell outside of members")
        precondition(sourceIndexPath.row < trainMembers.count, "Attempt to move non-member")

        // Only allow reordering within the members list, not past the end, or to other sections.
        guard proposedDestinationIndexPath.section == 2 else { return sourceIndexPath }
        guard proposedDestinationIndexPath.row < trainMembers.count else { return sourceIndexPath }

        return proposedDestinationIndexPath
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let train = train else { return }

        precondition(fromIndexPath.section == 2, "Attempt to move cell outside of members")
        precondition(fromIndexPath.row < trainMembers.count, "Attempt to move non-member")

        precondition(to.section == 2, "Attempt to move cell out of members")
        precondition(to.row < trainMembers.count, "Attempt to move outside of bounds")

        // Remove from the members list first, and then insert at the new index path. This will
        // do the right thing when moving up, because removing below doesn't change the above
        // objects. It will also do the right thing when moving down, because the other objects
        // move up, making way for it and leaving a gap at the new index path.
        train.moveMember(from: fromIndexPath.row, to: to.row)
    }
    
    // MARK: - Presentation Delegate
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmDiscardChanges()
    }

    // MARK: - Presenter API

    func editTrain(_ train: Train, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        self.train = managedObjectContext!.object(with: train.objectID) as? Train
    }

    func addTrain(completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        train = Train(context: managedObjectContext!)
    }

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
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let train = train else { return }

        // Update editing state whenever our train object, or any of its members, are updated.
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updatedObjects.contains(train) ||
                !updatedObjects.isDisjoint(with: trainMembers)
        {
            updateEditingState()
        }

        // Check for a refresh of our train object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(train) ||
                !refreshedObjects.isDisjoint(with: trainMembers)
        {
            tableView.reloadData()
        }
    }
    
    // MARK: - Commit methods
    
    enum Result {
        case canceled
        case saved(Train)
        case deleted
    }
    
    private var completionHandler: ((Result) -> Void)!

    func hasChanges() -> Bool {
        guard let train = train else { return false }
        guard let trainMembers = train.members else { return train.hasChanges }
        
        return trainMembers.reduce(into: train.hasChanges) {
            $0 = $0 || ($1 as! TrainMember).hasChanges
        }
    }
    
    func isValid() -> Bool {
        guard let train = train else { return false }
        
        do {
            if train.isInserted {
                try train.validateForInsert()
            } else if train.isUpdated {
                try train.validateForUpdate()
            }
            
            guard let members = train.members else { return true }
            for case let member as TrainMember in members {
                if member.isInserted {
                    try member.validateForInsert()
                } else if member.isUpdated {
                    try member.validateForUpdate()
                }
            }
            
            return true
        } catch {
            return false
        }
    }
    
    func updateEditingState() {
        // Disable interaction and pull-to-dismiss when there are pending changes.
        isModalInPresentation = hasChanges()
        
        // Enable the save button only if there has been a change, and that the result is valid.
        saveButton.isEnabled = hasChanges() && isValid()
    }
    
    func confirmDiscardChanges() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if isValid() {
            alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
                self.saveTrain()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.discardChanges()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Set iPad presentation.
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = cancelButton
        }
        
        present(alert, animated: true)
    }
    
    func discardChanges() {
        completionHandler?(.canceled)
    }

    func saveTrain() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let train = train else { return }
        
        do {
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }
            
            // Give the view context a chance to receive the merge notification before grabbing
            // a copy of the object and running the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                let train = viewContext.object(with: train.objectID) as! Train
                self.completionHandler?(.saved(train))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func confirmDeleteTrain(from indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Train", style: .destructive) { _ in
            self.deleteTrain()
        })
        
        // Cancel case, deselect the table row.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
        
        // Set iPad presentation.
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: indexPath)
        }
        
        present(alert, animated: true)
    }

    func deleteTrain() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let train = train else { return }

        do {
            managedObjectContext.delete(train)
            try managedObjectContext.save()

            // Give the view context a chance to receive the merge notification before running
            // the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                self.completionHandler?(.deleted)
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        discardChanges()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        saveTrain()
    }

}
