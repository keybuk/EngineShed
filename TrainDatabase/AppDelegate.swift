//
//  AppDelegate.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/4/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //let importer = Importer(directory: "/Users/scott/Downloads/Model Railway Export", into: persistentContainer.viewContext)
        //importer.start()

        let fetchRequest: NSFetchRequest<ModelManagedObject> = ModelManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "modelClass", ascending: true),
            NSSortDescriptor(key: "number", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "dispositionRawValue", ascending: true)
        ]
        
        //fetchRequest.predicate = NSPredicate(format: "ANY tasks.title =[c] %@", "decoder", "dcc conversion")
        //fetchRequest.predicate = NSPredicate(format: "ANY tasks.title =[c] %@ AND ANY tasks.title =[c] %@", "decoder", "dcc conversion")
        
        // NONE field = value get translated to ANY field != value, which is totally wrong;
        // so we use SUBQUERY
        //fetchRequest.predicate = NSPredicate(format: "ANY tasks.title =[c] %@ AND SUBQUERY(tasks, $task, $task.title =[c] %@).@count = 0", "decoder", "dcc conversion")

        //fetchRequest.predicate = NSPredicate(format: "(ANY tasks.title =[c] %@ OR ANY tasks.title =[c] %@) AND SUBQUERY(tasks, $task, $task.title =[c] %@).@count = 0", "speaker", "examine speaker", "decoder")
        
        // probably check for pass through in couplings:
        //fetchRequest.predicate = NSPredicate(format: "dispositionRawValue = %@ AND lightings.@count > 0 AND decoder = NULL AND SUBQUERY(tasks, $task, $task.title =[c] %@).@count = 0", ModelDisposition.normal.rawValue, "decoder")

        // usually zero:
        //fetchRequest.predicate = NSPredicate(format: "dispositionRawValue = %@ AND motor != '' AND motor != NULL AND decoder = NULL AND SUBQUERY(tasks, $task, $task.title =[c] %@).@count = 0", ModelDisposition.normal.rawValue, "decoder")
        //fetchRequest.predicate = NSPredicate(format: "dispositionRawValue = %@ AND socket != '' AND socket != NULL AND lightings.@count = 0 AND motor != '' AND motor != NULL AND decoder = NULL AND SUBQUERY(tasks, $task, $task.title =[c] %@).@count = 0", ModelDisposition.normal.rawValue, "decoder")

        // Order Sound File:
        fetchRequest.predicate = NSPredicate(format: "ANY tasks.title =[c] %@ AND decoder != NULL AND SUBQUERY(tasks, $task, $task.title =[c] %@).@count == 0", "sound file", "decoder")
        

        

        
        let modelObjects = try! persistentContainer.viewContext.fetch(fetchRequest)
        for modelObject in modelObjects {
            let model = Model(managedObject: modelObject)
            print("\(model) \(model.tasks) \(model.decoder!.serialNumber)")
        }
        
        print("")
        print(modelObjects.count)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func backup() throws {
        print("Backing up...")
        let fileManager = FileManager.default
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH-mm-ss"
        let backupName = dateFormatter.string(from: Date())
        
        let backupURL = fileManager.temporaryDirectory.appendingPathComponent(backupName, isDirectory: true)
        try fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true, attributes: nil)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let decoderTypes = try! DecoderType.all(in: persistentContainer.viewContext)
        try encoder.encode(decoderTypes).write(to: backupURL.appendingPathComponent("Decoders.json"))
        print("Decoders encoded")

        let purchases = try! Purchase.all(in: persistentContainer.viewContext)
        try encoder.encode(purchases).write(to: backupURL.appendingPathComponent("Purchases.json"))
        print("Purchases encoded")

        let trains = try! Train.all(in: persistentContainer.viewContext)
        try encoder.encode(trains).write(to: backupURL.appendingPathComponent("Trains.json"))
        print("Trains done")

        let imagesURL = backupURL.appendingPathComponent("Images", isDirectory: true)
        try fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: true, attributes: nil)

        for purchase in purchases {
            for model in purchase.models {
                if let imageFilename = model.imageFilename, let imageURL = model.imageURL {
                    try fileManager.copyItem(at: imageURL, to: imagesURL.appendingPathComponent(imageFilename))
                }
            }
        }
        print("Images done")
        
        let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let backupFile = downloadsURL.appendingPathComponent("Backup \(backupName).zip")
        
        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: backupURL, options: .forUploading, error: &error) { zippedURL in
            do {
                try fileManager.copyItem(at: zippedURL, to: backupFile)
            } catch let err {
                error = err as NSError
            }
        }
        print("Zip done")
        
        if let error = error { throw error }
        try fileManager.removeItem(at: backupURL)

        print("Backup complete")
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TrainDatabase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

    @IBAction func selectSearchField(_ sender: Any) {
        guard let windowController = NSApplication.shared.mainWindow?.windowController as? WindowController else { return }
        windowController.window?.makeFirstResponder(windowController.searchField)
    }
    

}
