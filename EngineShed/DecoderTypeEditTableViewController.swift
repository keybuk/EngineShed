//
//  DecoderTypeEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class DecoderTypeEditTableViewController : UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    /// Private read-write context with a main queue concurrency type.
    private var managedObjectContext: NSManagedObjectContext? {
        didSet {
            // Register for notifications of changes to this context so we can update field values when changed outside this view.
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }
    
    /// DecoderType being edited in this view, on `managedObjectContext`.
    private var decoderType: DecoderType? {
        didSet {
            // Use KVO to keep the save button state up to date.
            observeDecoderType()
        }
    }

    enum Result {
        case canceled
        case saved(DecoderType)
        case deleted
    }

    private var completionHandler: ((Result) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the initial save button state.
        updateSaveButton()
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
        case 3:
            precondition(!(decoderType?.isInserted ?? true), "Unexpected delete decoder type section in inserted decoder type")

            // Confirm train deletion using an alert.
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete Decoder Type", style: .destructive) { action in
                self.deleteDecoderType()
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

    func editDecoderType(_ decoderType: DecoderType, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

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

        decoderType = DecoderType(context: managedObjectContext!)
    }

    // MARK: - Object observation
    
    var observers: [NSKeyValueObservation] = []

    func observeDecoderType() {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

        observers.removeAll()
        guard let decoderType = decoderType else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(decoderType.observe(\.manufacturer) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.productCode) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.productFamily) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.productDescription) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.socket) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.isProgrammable) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.hasRailCom) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.hasSound) { (_, _) in self.updateSaveButton() })
        observers.append(decoderType.observe(\.minimumStock) { (_, _) in self.updateSaveButton() })
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let decoderType = decoderType else { return }

        // Check for a refresh of our decoder type object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(decoderType)
        {
            tableView.reloadData()
        }
    }

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        completionHandler?(.canceled)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
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

    /// Returns `true` if `decoderType` has changes, and is in a valid state to be saved.
    func canSave() -> Bool {
        guard let decoderType = decoderType else { return false }

        do {
            var isChanged = false
            
            if decoderType.isInserted {
                try decoderType.validateForInsert()
                isChanged = true
            } else if decoderType.isUpdated {
                try decoderType.validateForUpdate()
                isChanged = true
            }

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
        if segue.identifier == "decoderTypeSocketPicker" {
            let viewController = segue.destination as! DecoderTypeSocketPickerTableViewController
            viewController.decoderType = decoderType
        }
    }

}
