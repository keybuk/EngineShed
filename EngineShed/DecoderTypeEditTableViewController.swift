//
//  DecoderTypeEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class DecoderTypeEditTableViewController : UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var decoderType: DecoderType?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateEditingState()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (decoderType?.isInserted ?? true) ? 3 : 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 4
        case 2: return 1
        case 3: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeManufacturerEdit", for: indexPath) as! DecoderTypeManufacturerEditTableViewCell
                cell.decoderType = decoderType
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeProductCodeEdit", for: indexPath) as! DecoderTypeProductCodeEditTableViewCell
                cell.decoderType = decoderType
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeProductFamilyEdit", for: indexPath) as! DecoderTypeProductFamilyEditTableViewCell
                cell.decoderType = decoderType
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeProductDescriptionEdit", for: indexPath) as! DecoderTypeProductDescriptionEditTableViewCell
                cell.decoderType = decoderType
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeSocketEdit", for: indexPath) as! DecoderTypeSocketEditTableViewCell
                cell.decoderType = decoderType
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeIsProgrammableEdit", for: indexPath) as! DecoderTypeIsProgrammableEditTableViewCell
                cell.decoderType = decoderType
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeHasRailComEdit", for: indexPath) as! DecoderTypeHasRailComEditTableViewCell
                cell.decoderType = decoderType
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeHasSoundEdit", for: indexPath) as! DecoderTypeHasSoundEditTableViewCell
                cell.decoderType = decoderType
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeMinimumStockEdit", for: indexPath) as! DecoderTypeMinimumStockEditTableViewCell
                cell.decoderType = decoderType
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 3:
            precondition(!(decoderType?.isInserted ?? true), "Unexpected delete decoder type section in inserted decoder type")
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderTypeDelete", for: indexPath) as! DecoderTypeDeleteTableViewCell
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
        case 2: break
        case 3: confirmDeleteDecoderType(from: indexPath)
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        // Default handling
        if let cell = tableView.cellForRow(at: indexPath),
            cell.canBecomeFirstResponder
        {
            cell.becomeFirstResponder()
        }
    }

    // MARK: - Presentation Delegate

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmDiscardChanges()
    }

    // MARK: - Presenter API

    func editDecoderType(_ decoderType: DecoderType, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        self.decoderType = managedObjectContext!.object(with: decoderType.objectID) as? DecoderType
    }

    func addDecoderType(completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        decoderType = DecoderType(context: managedObjectContext!)
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let decoderType = decoderType else { return }

        // Update editing state whenever our decoder type object is updated.
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updatedObjects.contains(decoderType)
        {
            updateEditingState()
        }

        // Check for a refresh of our decoder type object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(decoderType)
        {
            tableView.reloadData()
        }
    }

    // MARK: - Commit methods
    
    enum Result {
        case canceled
        case saved(DecoderType)
        case deleted
    }
    
    private var completionHandler: ((Result) -> Void)!

    func hasChanges() -> Bool {
        guard let decoderType = decoderType else { return false }

        return decoderType.hasChanges
    }
    
    func isValid() -> Bool {
        guard let decoderType = decoderType else { return false }
        
        do {
            if decoderType.isInserted {
                try decoderType.validateForInsert()
            } else if decoderType.isUpdated {
                try decoderType.validateForUpdate()
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
                self.saveDecoderType()
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

    func saveDecoderType() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let decoderType = decoderType else { return }

        do {
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }

            // Give the view context a chance to receive the merge notification before grabbing
            // a copy of the object and running the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                let decoderType = viewContext.object(with: decoderType.objectID) as! DecoderType
                self.completionHandler?(.saved(decoderType))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func confirmDeleteDecoderType(from indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Decoder Type", style: .destructive) { _ in
            self.deleteDecoderType()
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
    
    func deleteDecoderType() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let decoderType = decoderType else { return }
        
        do {
            managedObjectContext.delete(decoderType)
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
        saveDecoderType()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "decoderTypeSocketPicker" {
            let viewController = segue.destination as! DecoderTypeSocketPickerTableViewController
            viewController.decoderType = decoderType
        }
    }

}
