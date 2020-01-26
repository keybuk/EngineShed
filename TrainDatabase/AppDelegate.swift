//
//  AppDelegate.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/4/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData
import CloudKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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

        let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let backupFile = downloadsURL.appendingPathComponent("Backup \(backupName).zip")
        
        let coordinator = NSFileCoordinator()
        var error: NSError?
        var copyError: NSError?
        coordinator.coordinate(readingItemAt: backupURL, options: .forUploading, error: &error) { zippedURL in
            do {
                try fileManager.copyItem(at: zippedURL, to: backupFile)
            } catch let err {
                copyError = err as NSError
            }
        }
        print("Zip done")
        
        if let error = error { throw error }
        if let error = copyError { throw error }
        try fileManager.removeItem(at: backupURL)

        print("Backup complete")
    }

    func upload(callback: @escaping () -> Void) throws {
        print("Uploading to iCloud...")

        let container = CKContainer(identifier: "iCloud.com.netsplit.TrainDatabase")
        let database = container.privateCloudDatabase
        let zoneID = CKRecordZone.ID(zoneName: "EngineShed", ownerName: CKCurrentUserDefaultName)
        let zone = CKRecordZone(zoneID: zoneID)

        var records: [CKRecord] = []
        var trainMemberRecords: [TrainMember : CKRecord] = [:]

        for train in try! Train.all(in: persistentContainer.viewContext) {
            let trainRecord = CKRecord.fromSystemFields(
                &train.managedObject.systemFields,
                recordID: &train.managedObject.recordID,
                orCreate: "Train", in: zoneID)
            trainRecord["name"] = train.name as NSString
            trainRecord["details"] = train.details as NSString
            trainRecord["notes"] = train.notes as NSString

            var members: [CKRecord.Reference] = []

            for trainMember in train.members {
                let trainMemberRecord = CKRecord.fromSystemFields(
                    &trainMember.managedObject.systemFields,
                    recordID: &trainMember.managedObject.recordID,
                    orCreate: "TrainMember", in: zoneID)
                trainMemberRecord["train"] = CKRecord.Reference(record: trainRecord, action: .deleteSelf)
                trainMemberRecord["title"] = trainMember.title as NSString
                trainMemberRecord["isFlipped"] = trainMember.isFlipped as NSNumber
                records.append(trainMemberRecord)

                members.append(CKRecord.Reference(record: trainMemberRecord, action: .none))
                trainMemberRecords[trainMember] = trainMemberRecord
            }

            trainRecord["members"] = members as NSArray
            records.append(trainRecord)
        }

        var decoderRecords: [Decoder : CKRecord] = [:]

        for decoderType in try! DecoderType.all(in: persistentContainer.viewContext) {
            let decoderTypeRecord = CKRecord.fromSystemFields(
                &decoderType.managedObject.systemFields,
                recordID: &decoderType.managedObject.recordID,
                orCreate: "DecoderType", in: zoneID)
            decoderTypeRecord["manufacturer"] = decoderType.manufacturer as NSString
            decoderTypeRecord["productCode"] = decoderType.productCode as NSString
            decoderTypeRecord["productFamily"] = decoderType.productFamily as NSString
            decoderTypeRecord["productDescription"] = decoderType.productDescription as NSString
            decoderTypeRecord["socket"] = decoderType.socket as NSString
            decoderTypeRecord["isProgrammable"] = decoderType.isProgrammable as NSNumber
            decoderTypeRecord["hasSound"] = decoderType.hasSound as NSNumber
            decoderTypeRecord["hasRailCom"] = decoderType.hasRailCom as NSNumber
            decoderTypeRecord["minimumStock"] = decoderType.minimumStock as NSNumber
            records.append(decoderTypeRecord)

            for decoder in decoderType.decoders {
                let decoderRecord = CKRecord.fromSystemFields(
                    &decoder.managedObject.systemFields,
                    recordID: &decoder.managedObject.recordID,
                    orCreate: "Decoder", in: zoneID)
                decoderRecord["type"] = CKRecord.Reference(record: decoderTypeRecord, action: .deleteSelf)
                decoderRecord["serialNumber"] = decoder.serialNumber as NSString
                decoderRecord["firmwareVersion"] = decoder.firmwareVersion as NSString
                decoderRecord["address"] = decoder.address as NSNumber
                decoderRecord["soundAuthor"] = decoder.soundAuthor as NSString
                decoderRecord["soundProject"] = decoder.soundProject as NSString

                if let firmwareDate = decoder.firmwareDate {
                    let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                    archiver.encode(firmwareDate, forKey: "FirmwareDate")
                    archiver.finishEncoding()
                    decoderRecord["firmwareDate"] = archiver.encodedData as NSData
                } else {
                    decoderRecord["firmwareDate"] = nil
                }

                records.append(decoderRecord)

                decoderRecords[decoder] = decoderRecord
            }
        }

        for purchase in try! Purchase.all(in: persistentContainer.viewContext) {
            let purchaseRecord = CKRecord.fromSystemFields(
                &purchase.managedObject.systemFields,
                recordID: &purchase.managedObject.recordID,
                orCreate: "Purchase", in: zoneID)
            purchaseRecord["manufacturer"] = purchase.manufacturer as NSString
            purchaseRecord["catalogNumber"] = purchase.catalogNumber as NSString
            purchaseRecord["catalogDescription"] = purchase.catalogDescription as NSString
            purchaseRecord["catalogYear"] = purchase.catalogYear as NSNumber
            purchaseRecord["limitedEdition"] = purchase.limitedEdition as NSString
            purchaseRecord["limitedEditionNumber"] = purchase.limitedEditionNumber as NSNumber
            purchaseRecord["limitedEditionCount"] = purchase.limitedEditionCount as NSNumber
            purchaseRecord["store"] = purchase.store as NSString
            purchaseRecord["price"] = purchase.price as NSNumber?
            purchaseRecord["condition"] = purchase.condition?.rawValue as NSNumber?
            purchaseRecord["valuation"] = purchase.valuation as NSNumber?
            purchaseRecord["notes"] = purchase.notes as NSString

            if let date = purchase.date {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode(date, forKey: "Date")
                archiver.finishEncoding()
                purchaseRecord["date"] = archiver.encodedData as NSData
            } else {
                purchaseRecord["date"] = nil
            }

            if let price = purchase.price {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode(price, forKey: "Price")
                archiver.finishEncoding()
                purchaseRecord["price"] = archiver.encodedData as NSData
            } else {
                purchaseRecord["price"] = nil
            }

            if let valuation = purchase.valuation {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode(valuation, forKey: "Valuation")
                archiver.finishEncoding()
                purchaseRecord["valuation"] = archiver.encodedData as NSData
            } else {
                purchaseRecord["valuation"] = nil
            }

            var models: [CKRecord.Reference] = []

            for model in purchase.models {
                let modelRecord = CKRecord.fromSystemFields(
                    &model.managedObject.systemFields,
                    recordID: &model.managedObject.recordID,
                    orCreate: "Model", in: zoneID)
                modelRecord["purchase"] = CKRecord.Reference(record: purchaseRecord, action: .deleteSelf)
                modelRecord["classification"] = model.classification?.rawValue as NSNumber?
                modelRecord["image"] = model.imageData.flatMap({ (try? CKDataAsset(data: $0)) as CKAsset? })
                modelRecord["class"] = model.modelClass as NSString
                modelRecord["number"] = model.number as NSString
                modelRecord["name"] = model.name as NSString
                modelRecord["livery"] = model.livery as NSString
                modelRecord["details"] = model.details as NSString
                modelRecord["era"] = model.era?.rawValue as NSNumber?
                modelRecord["disposition"] = model.disposition?.rawValue as NSNumber?
                modelRecord["motor"] = model.motor as NSString
                if !model.lights.isEmpty { modelRecord["lights"] = Array(model.lights) as NSArray }
                modelRecord["socket"] = model.socket as NSString
                modelRecord["speaker"] = model.speaker as NSString
                if !model.speakerFitting.isEmpty { modelRecord["speakerFittings"] = Array(model.speakerFitting) as NSArray }
                if !model.couplings.isEmpty { modelRecord["couplings"] = Array(model.couplings) as NSArray }
                if !model.features.isEmpty { modelRecord["features"] = Array(model.features) as NSArray }
                if !model.detailParts.isEmpty {
                    modelRecord["detailParts"] = model.detailParts.map({ $0.title }) as NSArray
                    let fitted = model.detailParts.filter({ $0.isFitted })
                    if !fitted.isEmpty { modelRecord["fittedDetailParts"] = fitted.map({ $0.title }) as NSArray }
                }
                if !model.modifications.isEmpty {
                    modelRecord["modifications"] = Array(model.modifications) as NSArray }
                if !model.tasks.isEmpty { modelRecord["tasks"] = Array(model.tasks) as NSArray }
                modelRecord["notes"] = model.notes as NSString

                if let lastRun = model.lastRun {
                    let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                    archiver.encode(lastRun, forKey: "LastRun")
                    archiver.finishEncoding()
                    modelRecord["lastRun"] = archiver.encodedData as NSData
                } else {
                    modelRecord["lastRun"] = nil
                }

                if let lastOil = model.lastOil {
                    let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                    archiver.encode(lastOil, forKey: "LastOil")
                    archiver.finishEncoding()
                    modelRecord["lastOil"] = archiver.encodedData as NSData
                } else {
                    modelRecord["lastOil"] = nil
                }

                records.append(modelRecord)

                models.append(CKRecord.Reference(record: modelRecord, action: .none))

                if let decoder = model.decoder {
                    if let decoderRecord = decoderRecords[decoder] {
                        decoderRecord["model"] = CKRecord.Reference(record: modelRecord, action: .none)
                    } else {
                        let decoderRecord = CKRecord.fromSystemFields(
                            &decoder.managedObject.systemFields,
                            recordID: &decoder.managedObject.recordID,
                            orCreate: "Decoder", in: zoneID)
                        decoderRecord["model"] = CKRecord.Reference(record: modelRecord, action: .none)
                        decoderRecord["serialNumber"] = decoder.serialNumber as NSString
                        decoderRecord["firmwareVersion"] = decoder.firmwareVersion as NSString
                        decoderRecord["address"] = decoder.address as NSNumber
                        decoderRecord["soundAuthor"] = decoder.soundAuthor as NSString
                        decoderRecord["soundProject"] = decoder.soundProject as NSString

                        if let firmwareDate = decoder.firmwareDate {
                            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                            archiver.encode(firmwareDate, forKey: "FirmwareDate")
                            archiver.finishEncoding()
                            decoderRecord["firmwareDate"] = archiver.encodedData as NSData
                        } else {
                            decoderRecord["firmwareDate"] = nil
                        }

                        records.append(decoderRecord)

                        decoderRecords[decoder] = decoderRecord
                    }
                }

                if let trainMember = model.trainMember {
                    if let trainMemberRecord = trainMemberRecords[trainMember] {
                        trainMemberRecord["model"] = CKRecord.Reference(record: modelRecord, action: .none)
                    } else {
                        fatalError("Train member without train")
                    }
                }
            }

            purchaseRecord["models"] = models as NSArray
            records.append(purchaseRecord)
        }

        try! persistentContainer.viewContext.save()
        print("\(records.count) records to upload")

        let callbackOperation = BlockOperation(block: callback)

        // Create the zone.
        let zoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        zoneOperation.qualityOfService = .utility

        zoneOperation.modifyRecordZonesCompletionBlock = { savedRecordZones, deletedRecordZoneIDs, error in
            if let error = error {
                fatalError("Couldn't update zone \(error)")
            }
        }

        callbackOperation.addDependency(zoneOperation)
        database.add(zoneOperation)


        saveRecords(records, in: database, dependency: zoneOperation, whenComplete: callbackOperation)
        OperationQueue.main.addOperation(callbackOperation)
    }

    func saveRecords(_ records: [CKRecord], in database: CKDatabase, dependency zoneOperation: CKDatabaseOperation, whenComplete callbackOperation: Operation) {
        if records.count < 400 {
            _saveRecords(records, in: database, dependency: zoneOperation, whenComplete: callbackOperation)
        } else {
            let s = records.count / 2
            self.saveRecords(Array(records[..<s]), in: database, dependency: zoneOperation, whenComplete: callbackOperation)
            self.saveRecords(Array(records[s...]), in: database, dependency: zoneOperation, whenComplete: callbackOperation)
        }
    }

    func _saveRecords(_ records: [CKRecord], in database: CKDatabase, dependency zoneOperation: CKDatabaseOperation, whenComplete callbackOperation: Operation) {
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        saveOperation.qualityOfService = .utility
        saveOperation.savePolicy = .allKeys

        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil

        saveOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error as? CKError,
                error.code == .limitExceeded
            {
                print("Limit exceeded, splitting request in half")

                let s = records.count / 2
                self._saveRecords(Array(records[..<s]), in: database, dependency: zoneOperation, whenComplete: callbackOperation)
                self._saveRecords(Array(records[s...]), in: database, dependency: zoneOperation, whenComplete: callbackOperation)
            } else if let error = error {
                fatalError("Couldn't save records \(error)")
            } else if let savedRecords = savedRecords {
                print("Saved \(savedRecords.count) records")

                for record in savedRecords {
                    NSManagedObject.fromRecord(record, in: context)
                }

                try! context.save()
            }
        }

        callbackOperation.addDependency(saveOperation)
        saveOperation.addDependency(zoneOperation)
        database.add(saveOperation)
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


extension CKRecord {

    static func fromSystemFields(_ systemFields: inout Data?, recordID: inout CKRecord.ID?, orCreate recordType: String, in zoneID: CKRecordZone.ID) -> CKRecord {

        if let systemFields = systemFields {
            let archiver = NSKeyedUnarchiver(forReadingWith: systemFields)
            archiver.requiresSecureCoding = true

            if let record = CKRecord(coder: archiver) {
                return record
            }

            archiver.finishDecoding()
        }

        let recordName = UUID().uuidString
        recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let record = CKRecord(recordType: recordType, recordID: recordID!)

        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        systemFields = data as Data

        return record
    }

}

extension NSManagedObject {

    static func fromRecord(_ record: CKRecord, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: record.recordType)
        fetchRequest.predicate = NSPredicate(format: "recordID == %@", record.recordID)

        let objects = try! context.fetch(fetchRequest)
        guard let object = objects.first as? NSManagedObject else {
            print("Missing object for \(record)")
            return
        }

        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()

        object.setValue(record.recordID, forKey: "recordID")
        object.setValue(data as Data, forKey: "systemFields")
    }

}
