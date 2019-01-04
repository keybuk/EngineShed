//
//  TrainEditViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/1/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class TrainEditViewController : UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var train: Train?

    func editTrain(_ train: Train) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        // Merge from the store, but keep any local changes.
        managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext?.automaticallyMergesChangesFromParent = true
        managedObjectContext?.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext?.performAndWait {
            self.train = managedObjectContext?.object(with: train.objectID) as? Train
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        tableView.isEditing = true

        if let managedObjectContext = managedObjectContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return (train?.members?.count ?? 0) + 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainEditNameCell", for: indexPath) as! TrainEditNameCell
                cell.train = train
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainEditDetailsCell", for: indexPath) as! TrainEditDetailsCell
                cell.train = train
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainEditNotesCell", for: indexPath) as! TrainEditNotesCell
                cell.train = train
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case ..<(train?.members?.count ?? 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainEditMemberCell", for: indexPath) as! TrainEditMemberCell
                cell.trainMember = train?.members?[indexPath.row] as? TrainMember
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "trainAddMemberCell", for: indexPath) as! TrainAddMemberCell
                cell.train = train
                return cell
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return "Members"
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    // MARK: Editing support

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1: return false
        case 2: return true
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch indexPath.section {
        case 0: return .none
        case 1: return .none
        case 2:
            switch indexPath.row {
            case ..<(train?.members?.count ?? 0):
                return .delete
            default:
                return .insert
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let managedObjectContext = managedObjectContext else { preconditionFailure("No context to save to") }
        guard let train = train else { preconditionFailure("No train to change") }

        precondition(indexPath.section == 2, "Attempt to edit cell outside of members")

        if editingStyle == .delete {
            precondition(indexPath.row < train.members!.count, "Attempt to delete non-member cell")

            managedObjectContext.performAndWait {
                let trainMember = train.members![indexPath.row] as! TrainMember
                train.removeFromMembers(trainMember)
                managedObjectContext.delete(trainMember)
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            precondition(indexPath.row == train.members!.count, "Attempt to insert within members")

            managedObjectContext.performAndWait {
                let trainMember = TrainMember(context: managedObjectContext)
                train.addToMembers(trainMember)
            }

            tableView.insertRows(at: [indexPath], with: .bottom)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1: break
        case 2:
            switch indexPath.row {
            case ..<(train?.members!.count ?? 0): break
            default:
                // Call the delegate method as if the insertion control was tapped directly.
                self.tableView(tableView, commit: .insert, forRowAt: indexPath)
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    // MARK: Reordering support

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1: return false
        case 2:
            switch indexPath.row {
            case ..<(train?.members!.count ?? 0):
                return true
            default:
                return false
            }
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let train = train else { preconditionFailure("No train to change") }

        precondition(sourceIndexPath.section == 2, "Attempt to move cell outside of members")
        precondition(sourceIndexPath.row < train.members!.count, "Attempt to move non-member")

        guard proposedDestinationIndexPath.section == 2 else { return sourceIndexPath }
        guard proposedDestinationIndexPath.row < train.members!.count else { return sourceIndexPath }

        return proposedDestinationIndexPath
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let managedObjectContext = managedObjectContext else { preconditionFailure("No context to save to") }
        guard let train = train else { preconditionFailure("No train to change") }

        precondition(fromIndexPath.section == 2, "Attempt to move cell outside of members")
        precondition(fromIndexPath.row < train.members!.count, "Attempt to move non-member")

        precondition(to.section == 2, "Attempt to move cell out of members")
        precondition(to.row < train.members!.count, "Attempt to move outside of bounds")

        managedObjectContext.performAndWait {
            let trainMember = train.members![fromIndexPath.row] as! TrainMember

            train.removeFromMembers(at: fromIndexPath.row)
            train.insertIntoMembers(trainMember, at: to.row)
        }

        tableView.moveRow(at: fromIndexPath, to: to)
    }

    // MARK: Object lifecycle

    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let train = train else { return }

        // Check for a refresh of our train object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(train)
        {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }

        // Resign the first responder from whichever cell holds it.
        for cell in tableView.visibleCells {
            switch cell {
            case let cell as TrainEditNameCell: cell.textField.resignFirstResponder()
            case let cell as TrainEditDetailsCell: cell.textField.resignFirstResponder()
            case let cell as TrainEditNotesCell: cell.textView.resignFirstResponder()
            case let cell as TrainEditMemberCell: cell.textField.resignFirstResponder()
            default: continue
            }
        }

        do {
            try managedObjectContext.performAndWait {
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
            }

            self.dismiss(animated: true)
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

}
