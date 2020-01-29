//
//  DecoderEditTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class DecoderEditTableViewController : UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var persistentContainer: NSPersistentContainer?

    private var managedObjectContext: NSManagedObjectContext?
    private var decoder: Decoder?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateEditingState()
    }

    // MARK: - Table view data source

    var datePickerVisible = false
    let datePickerIndexPath = IndexPath(row: 2, section: 1)

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (decoder?.isInserted ?? true) ? 3 : 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2 + (datePickerVisible ? 1 : 0)
        case 2: return 4
        case 3: return 1
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Firmware"
        case 2: return "Sound Project"
        case 3: return nil
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSerialNumberEdit", for: indexPath) as! DecoderSerialNumberEditTableViewCell
                cell.decoder = decoder
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderAddressEdit", for: indexPath) as! DecoderAddressEditTableViewCell
                cell.decoder = decoder
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderFirmwareVersionEdit", for: indexPath) as! DecoderFirmwareVersionEditTableViewCell
                cell.decoder = decoder
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderFirmwareDateEdit", for: indexPath) as! DecoderFirmwareDateEditTableViewCell
                cell.decoder = decoder
                return cell
            case 2 where datePickerVisible:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderFirmwareDatePicker", for: indexPath) as! DecoderFirmwareDatePickerTableViewCell
                cell.decoder = decoder
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundAuthorEdit", for: indexPath) as! DecoderSoundAuthorEditTableViewCell
                cell.decoder = decoder
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundProjectEdit", for: indexPath) as! DecoderSoundProjectEditTableViewCell
                cell.decoder = decoder
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundProjectVersionEdit", for: indexPath) as! DecoderSoundProjectVersionEditTableViewCell
                cell.decoder = decoder
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderSoundSettingsEdit", for: indexPath) as! DecoderSoundSettingsEditTableViewCell
                cell.decoder = decoder
                return cell
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 3:
            precondition(!(decoder?.isInserted ?? true), "Unexpected delete decoder section in inserted decoder")
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "decoderDelete", for: indexPath) as! DecoderDeleteTableViewCell
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
        case 1:
            switch indexPath.row {
            case 1:
                weak var dateEditCell = tableView.cellForRow(at: indexPath) as? DecoderFirmwareDateEditTableViewCell
                tableView.deselectRow(at: indexPath, animated: true)

                if !datePickerVisible {
                    datePickerVisible = true

                    tableView.insertRows(at: [datePickerIndexPath], with: .top)
                    tableView.scrollToRow(at: datePickerIndexPath, at: .middle, animated: true)

                    dateEditCell?.pickerVisible = datePickerVisible

                    // Make the date picker the first responder, and when it loses that status,
                    // hide the cell again.
                    if let cell = tableView.cellForRow(at: datePickerIndexPath) as? DecoderFirmwareDatePickerTableViewCell,
                        cell.canBecomeFirstResponder,
                        cell.becomeFirstResponder()
                    {
                        cell.resignFirstResponderBlock = {
                            if self.datePickerVisible {
                                self.datePickerVisible = false

                                self.tableView.deleteRows(at: [self.datePickerIndexPath], with: .top)
                                dateEditCell?.pickerVisible = self.datePickerVisible
                            }
                        }
                    }
                } else {
                    datePickerVisible = false

                    tableView.deleteRows(at: [datePickerIndexPath], with: .top)
                    dateEditCell?.pickerVisible = datePickerVisible
                }

            default: break
            }
        case 3: confirmDeleteDecoder(from: indexPath)
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

    func editDecoder(_ decoder: Decoder, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        self.decoder = managedObjectContext!.object(with: decoder.objectID) as? Decoder
    }

    func addDecoder(type decoderType: DecoderType, completionHandler: @escaping ((Result) -> Void)) {
        guard let persistentContainer = persistentContainer else { preconditionFailure("No persistent container") }

        self.completionHandler = completionHandler

        // Use a read-write main queue context that saves to the store. In case of changes to the
        // store (e.g. from sync or save in other window), merge but keep any local changes.
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext!.automaticallyMergesChangesFromParent = true
        managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)

        decoder = Decoder(context: managedObjectContext!)

        if let decoderType = managedObjectContext!.object(with: decoderType.objectID) as? DecoderType {
            decoderType.addDecoder(decoder!)
        }
    }

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        assert(notification.object as? NSManagedObjectContext == managedObjectContext, "Notification callback called with wrong managed object context")
        guard let userInfo = notification.userInfo else { return }
        guard let decoder = decoder else { return }

        // Update editing state whenever our decoder object is updated.
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updatedObjects.contains(decoder)
        {
            updateEditingState()
        }

        // Check for a refresh of our decoder type object, by sync from cloud or merge after save
        // from other context, and reload the table.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            refreshedObjects.contains(decoder)
        {
            tableView.reloadData()
        }
    }

    // MARK: - Commit methods

    enum Result {
        case canceled
        case saved(Decoder)
        case deleted
    }

    private var completionHandler: ((Result) -> Void)!

    func hasChanges() -> Bool {
        guard let decoder = decoder else { return false }

        return decoder.hasChanges
    }

    func isValid() -> Bool {
        guard let decoder = decoder else { return false }
        
        do {
            if decoder.isInserted {
                try decoder.validateForInsert()
            } else if decoder.isUpdated {
                try decoder.validateForUpdate()
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
                self.saveDecoder()
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

    func saveDecoder() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let decoder = decoder else { return }

        do {
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }

            // Give the view context a chance to receive the merge notification before grabbing
            // a copy of the object and running the completion handler.
            view.isUserInteractionEnabled = false
            viewContext.perform {
                let decoder = viewContext.object(with: decoder.objectID) as! Decoder
                self.completionHandler?(.saved(decoder))
            }
        } catch {
            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func confirmDeleteDecoder(from indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Decoder", style: .destructive) { _ in
            self.deleteDecoder()
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

    func deleteDecoder() {
        guard let viewContext = persistentContainer?.viewContext else { return }
        guard let managedObjectContext = managedObjectContext else { return }
        guard let decoder = decoder else { return }
        
        do {
            managedObjectContext.delete(decoder)
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
        saveDecoder()
    }

}
