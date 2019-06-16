//
//  ModelEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class ModelEditTableViewController : UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var model: Model?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateEditingState()
    }

    // MARK: - Table view data source

    var lastRunPickerVisible = false
    var lastOilPickerVisible = false

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6 + ((model?.isInserted ?? true) ? 0 : 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 8
        case 2: return 3
        case 3: return 1
        case 4: return 2 + (lastRunPickerVisible ? 1 : 0) + (lastOilPickerVisible ? 1 : 0)
        case 5: return 1
        case 6: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return "Electrical"
        case 3: return "Sound"
        case 4: return "Maintenance"
        case 5: return "Notes"
        case 6: return nil
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelImageEdit", for: indexPath) as! ModelImageEditTableViewCell
                cell.model = model
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelClassificationEdit", for: indexPath) as! ModelClassificationEditTableViewCell
                cell.model = model
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelClassEdit", for: indexPath) as! ModelClassEditTableViewCell
                cell.model = model
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelNumberEdit", for: indexPath) as! ModelNumberEditTableViewCell
                cell.model = model
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelNameEdit", for: indexPath) as! ModelNameEditTableViewCell
                cell.model = model
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelLiveryEdit", for: indexPath) as! ModelLiveryEditTableViewCell
                cell.model = model
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelDetailsEdit", for: indexPath) as! ModelDetailsEditTableViewCell
                cell.model = model
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelEraEdit", for: indexPath) as! ModelEraEditTableViewCell
                cell.model = model
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelDispositionEdit", for: indexPath) as! ModelDispositionEditTableViewCell
                cell.model = model
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelMotorEdit", for: indexPath) as! ModelMotorEditTableViewCell
                cell.model = model
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelLightsEdit", for: indexPath) as! ModelLightsEditTableViewCell
                cell.model = model
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelSocketEdit", for: indexPath) as! ModelSocketEditTableViewCell
                cell.model = model
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelSpeakerEdit", for: indexPath) as! ModelSpeakerEditTableViewCell
                cell.model = model
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 4:
            let lastRunPickerOffset = lastRunPickerVisible ? 1 : 0
//            let lastOilPickerOffset = lastOilPickerVisible ? 1 : 0
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelLastRunEdit", for: indexPath) as! ModelLastRunEditTableViewCell
                cell.model = model
                return cell
            case 1 where lastRunPickerVisible:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelLastRunPicker", for: indexPath) as! ModelLastRunPickerTableViewCell
                cell.model = model
                return cell
            case 1 + lastRunPickerOffset:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelLastOilEdit", for: indexPath) as! ModelLastOilEditTableViewCell
                cell.model = model
                return cell
            case 2 + lastRunPickerOffset where lastOilPickerVisible:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelLastOilPicker", for: indexPath) as! ModelLastOilPickerTableViewCell
                cell.model = model
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 5:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelNotesEdit", for: indexPath) as! ModelNotesEditTableViewCell
                cell.model = model
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 6:
            precondition(!(model?.isInserted ?? true), "Unexpected delete model section in inserted model")
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "modelDelete", for: indexPath) as! ModelDeleteTableViewCell
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
        case 3: break
        case 4:
            let lastRunPickerOffset = lastRunPickerVisible ? 1 : 0
//            let lastOilPickerOffset = lastOilPickerVisible ? 1 : 0

            let lastRunPickerIndexPath = IndexPath(row: 1, section: 4)
            let lastOilPickerIndexPath = IndexPath(row: 2 + lastRunPickerOffset, section: 4)

            switch indexPath.row {
            case 0:
                weak var lastRunEditCell = tableView.cellForRow(at: indexPath) as? ModelLastRunEditTableViewCell
                tableView.deselectRow(at: indexPath, animated: true)

                if !lastRunPickerVisible {
                    lastRunPickerVisible = true

                    tableView.insertRows(at: [lastRunPickerIndexPath], with: .top)
                    tableView.scrollToRow(at: lastRunPickerIndexPath, at: .middle, animated: true)

                    lastRunEditCell?.pickerVisible = lastRunPickerVisible

                    // Make the date picker the first responder, and when it loses that status,
                    // hide the cell again.
                    if let cell = tableView.cellForRow(at: lastRunPickerIndexPath) as? ModelLastRunPickerTableViewCell,
                        cell.canBecomeFirstResponder,
                        cell.becomeFirstResponder()
                    {
                        cell.resignFirstResponderBlock = {
                            if self.lastRunPickerVisible {
                                self.lastRunPickerVisible = false

                                self.tableView.deleteRows(at: [lastRunPickerIndexPath], with: .top)
                                lastRunEditCell?.pickerVisible = self.lastRunPickerVisible
                            }
                        }
                    }
                } else {
                    lastRunPickerVisible = false

                    tableView.deleteRows(at: [lastRunPickerIndexPath], with: .top)
                    lastRunEditCell?.pickerVisible = lastRunPickerVisible
                }

            case 1 + lastRunPickerOffset:
                weak var lastOilEditCell = tableView.cellForRow(at: indexPath) as? ModelLastOilEditTableViewCell
                tableView.deselectRow(at: indexPath, animated: true)

                if !lastOilPickerVisible {
                    lastOilPickerVisible = true

                    tableView.insertRows(at: [lastOilPickerIndexPath], with: .top)
                    tableView.scrollToRow(at: lastOilPickerIndexPath, at: .middle, animated: true)

                    lastOilEditCell?.pickerVisible = lastOilPickerVisible

                    // Make the date picker the first responder, and when it loses that status,
                    // hide the cell again.
                    if let cell = tableView.cellForRow(at: lastOilPickerIndexPath) as? ModelLastOilPickerTableViewCell,
                        cell.canBecomeFirstResponder,
                        cell.becomeFirstResponder()
                    {
                        cell.resignFirstResponderBlock = {
                            let lastRunPickerOffset = self.lastRunPickerVisible ? 1 : 0
                            let lastOilPickerIndexPath = IndexPath(row: 2 + lastRunPickerOffset, section: 4)

                            if self.lastOilPickerVisible {
                                self.lastOilPickerVisible = false

                                self.tableView.deleteRows(at: [lastOilPickerIndexPath], with: .top)
                                lastOilEditCell?.pickerVisible = self.lastOilPickerVisible
                            }
                        }
                    }
                } else {
                    lastOilPickerVisible = false

                    tableView.deleteRows(at: [lastOilPickerIndexPath], with: .top)
                    lastOilEditCell?.pickerVisible = lastOilPickerVisible
                }
            default: break
            }
        case 5: break
        case 6: confirmDeleteModel(from: indexPath)
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

    func editModel(_ model: Model, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        self.model = managedObjectContext!.object(with: model.objectID) as? Model
    }

    func addModel(to purchase: Purchase, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        model = Model(context: managedObjectContext!)
        model!.purchase = managedObjectContext!.object(with: purchase.objectID) as? Purchase
    }
    
    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let model = model else { return }

        // Update editing state whenever our model object, or its linked decoder or trainMember,
        // are updated.
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updatedObjects.contains(model) ||
                (model.decoder.map({ updatedObjects.contains($0) }) ?? false) ||
                (model.trainMember.map({ updatedObjects.contains($0) }) ?? false)
        {
            updateEditingState()
        }

        // Check for refreshes of our model object, or its linked decoder or trainMember, meaning
        // they were updated by sync from cloud or merge after save from other context.
        // Reload the table in either case.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(model) ||
                (model.decoder.map({ refreshedObjects.contains($0) }) ?? false) ||
                (model.trainMember.map({ refreshedObjects.contains($0) }) ?? false)
        {
            tableView.reloadData()
        }
    }

    // MARK: - Commit methods
    
    enum Result {
        case canceled
        case saved(Model)
        case deleted
    }
    
    private var completionHandler: ((Result) -> Void)!

    func hasChanges() -> Bool {
        guard let model = model else { return false }

        // FIXME: check the decoder and train member

        return model.hasChanges
    }
    
    func isValid() -> Bool {
        guard let model = model else { return false }
        
        do {
            if model.isInserted {
                try model.validateForInsert()
            } else if model.isUpdated {
                try model.validateForUpdate()
            }
            
            // FIXME: check the decoder and train member
            
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
                self.saveModel()
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

    func saveModel() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let model = model else { return }

        do {
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }

            // Give the view context a chance to receive the merge notification before grabbing
            // a copy of the object and running the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                let model = viewContext.object(with: model.objectID) as! Model
                self.completionHandler?(.saved(model))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func confirmDeleteModel(from indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Model", style: .destructive) { _ in
            self.deleteModel()
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
    
    func deleteModel() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let model = model else { return }
        
        do {
            managedObjectContext.delete(model)
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
        saveModel()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelClassificationPicker" {
            let viewController = segue.destination as! ModelClassificationPickerTableViewController
            viewController.model = model
        } else if segue.identifier == "modelLiveryPicker" {
            let viewController = segue.destination as! ModelLiveryPickerTableViewController
            viewController.model = model
        } else if segue.identifier == "modelEraPicker" {
            let viewController = segue.destination as! ModelEraPickerTableViewController
            viewController.model = model
        } else if segue.identifier == "modelDispositionPicker" {
            let viewController = segue.destination as! ModelDispositionPickerTableViewController
            viewController.model = model
        } else if segue.identifier == "modelMotorPicker" {
            let viewController = segue.destination as! ModelMotorPickerTableViewController
            viewController.model = model
        } else if segue.identifier == "modelSocketPicker" {
            let viewController = segue.destination as! ModelSocketPickerTableViewController
            viewController.model = model
        } else if segue.identifier == "modelSpeakerPicker" {
            let viewController = segue.destination as! ModelSpeakerPickerTableViewController
            viewController.model = model
        }
    }

}
