//
//  ModelEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class ModelEditTableViewController : UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    /// Private read-write context with a main queue concurrency type.
    private var managedObjectContext: NSManagedObjectContext? {
        didSet {
            // Register for notifications of changes to this context so we can update field values when changed outside this view.
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }
    
    /// Model being edited in this view, on `managedObjectContext`.
    private var model: Model? {
        didSet {
            // Use KVO to keep the save button state up to date.
            observeModel()
        }
    }

    enum Result {
        case canceled
        case saved(Model)
        case deleted
    }

    private var completionHandler: ((Result) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view to editing so rows can be reordered and one-tap deleted, and also to show
        // the insert accessory.
        //        isEditing = true

        // Set the initial save button state.
        updateSaveButton()
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
        case 6:
            precondition(!(model?.isInserted ?? true), "Unexpected delete model section in inserted model")

            // Confirm train deletion using an alert.
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete Model", style: .destructive) { action in
                self.deleteModel()
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

        model = Model(context: managedObjectContext!)
        model!.purchase = managedObjectContext!.object(with: purchase.objectID) as? Purchase
    }
    
    // MARK: - Object observation

    var observers: [NSKeyValueObservation] = []

    func observeModel() {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

        observers.removeAll()
        guard let model = model else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(model.observe(\.imageData) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.classificationRawValue) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.modelClass) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.number) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.name) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.livery) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.details) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.eraRawValue) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.dispositionRawValue) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.motor) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.lights) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.socket) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.decoder) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.speaker) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.speakerFittings) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.couplings) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.features) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.detailParts) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.fittedDetailParts) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.modifications) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.lastRun) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.lastOil) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.tasks) { (_, _) in self.updateSaveButton() })
        observers.append(model.observe(\.notes) { (_, _) in self.updateSaveButton() })

        // FIXME: should observe decoder, and trainMember
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let model = model else { return }

        // Check for refreshes of our MODEL object, or its linked decoder or trainMember, meaning
        // they were updated by sync from cloud or merge after save from other context.
        // Reload the table in either case.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(model) ||
                (model.decoder.map({ refreshedObjects.contains($0) }) ?? false) ||
                (model.trainMember.map({ refreshedObjects.contains($0) }) ?? false)
        {
            tableView.reloadData()
        }

        // Check for the insertion of our model object, usually as a result of our own save
        // button, and clear it. This is something of a hack to avoid inserting the "Delete" section
        // before the picker view resigns the first responder (as a result of the user interaction
        // going to false), and the table row for that being deleted, throwing an inconsistency
        // exception.
        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
            insertedObjects.contains(model)
        {
            self.model = nil
        }
    }

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        completionHandler?(.canceled)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
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
    
    /// Returns `true` if `model` has changes, and is in a valid state to be saved.
    func canSave() -> Bool {
        guard let model = model else { return false }
        
        do {
            var isChanged = false
            
            if model.isInserted {
                try model.validateForInsert()
                isChanged = true
            } else if model.isUpdated {
                try model.validateForUpdate()
                isChanged = true
            }
            
            // FIXME: check the decoder and train member
            
            return isChanged
        } catch {
            return false
        }
    }

    func updateSaveButton() {
        // Enable the save button only if there has been a change, and that the result is valid.
        saveButton.isEnabled = canSave()
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
