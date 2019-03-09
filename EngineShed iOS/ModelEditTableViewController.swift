//
//  ModelEditTableViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class ModelEditTableViewController : UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var model: Model?

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

        // Register for notifications of changes to our background context so we can update the
        // field values when changed outside this view.
        if let managedObjectContext = managedObjectContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + ((model?.isInserted ?? true) ? 0 : 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 8
        case 2: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return nil
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
        case 2:
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

    // MARK: - Object management and observation

    func editModel(_ model: Model, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Merge from the store, but keep any local changes.
        managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext!.performAndWait {
            self.model = managedObjectContext!.object(with: model.objectID) as? Model

            // Use KVO to keep the save button state up to date.
            self.observeModel()
        }
    }

    func addModel(to purchase: Purchase, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Merge from the store, but keep any local changes.
        managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        managedObjectContext!.performAndWait {
            self.model = Model(context: managedObjectContext!)
            self.model!.purchase = managedObjectContext!.object(with: purchase.objectID) as? Purchase

            // Use KVO to keep the save button state up to date.
            self.observeModel()
        }
    }

    var observers: [NSKeyValueObservation] = []

    func observeModel() {
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
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        self.completionHandler?(.canceled)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let model = model else { return }

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
                let model = viewContext.object(with: model.objectID) as! Model
                self.completionHandler?(.saved(model))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func deleteModel() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let model = model else { return }

        do {
            try managedObjectContext.performAndWait {
                managedObjectContext.delete(model)

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
        guard let model = model else { return }

        // Enable the save button only if there has been a change, and that the result is valid.
        saveButton.isEnabled = managedObjectContext.performAndWait {
            var isChanged = false

            do {
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
        }
    }

}
