//
//  PreviewContent.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/23/20.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import CoreData

import Database

struct PreviewContent {
    var managedObjectContext: NSManagedObjectContext
    
    var purchases: [String: Purchase]
    var models: [String: Model]
    var trains: [String: Train]
    
    init() {
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        guard let modelURL = Bundle(identifier: "com.netsplit.EngineShed.Database")?
                .url(forResource: "EngineShed", withExtension: "momd")
        else {
            preconditionFailure("Missing bundle or managed object model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        else {
            preconditionFailure("Unable to open managed object model")
        }
        
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: URL(fileURLWithPath: "/dev/null"),
                options: nil)
            managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        } catch let error as NSError {
            preconditionFailure("Unable to open managed object model: \(error.localizedDescription)")
        }
        
        
        purchases = [:]
        models = [:]
        trains = [:]
        
        var purchase: Purchase
        var model: Model
        var train: Train
        var member: TrainMember
        
        
        purchase = Purchase(context: managedObjectContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3736"
        purchase.catalogDescription = "LNER, A1 Class, 4-6-2, 4472 'Flying Scotsman'"
        purchase.price = 272.99
        purchase.condition = .new
        purchases["R3736"] = purchase
        
        train = Train(context: managedObjectContext)
        train.name = "The Flying Scotsman"
        train.details = "Typical Hornby train set"
        trains["The Flying Scotsman"] = train
        
        model = purchase.addModel()
        model.classification = .locomotive
        model.disposition = .normal
        model.modelClass = "LNER A1 4-6-2"
        model.number = "4472"
        model.name = "Flying Scotsman"
        model.livery = "LNER, Apple Green"
        model.era = .theBigFour
        model.imageData = imageData(named: "R3736")
        models["R3736"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .coach
        model.disposition = .normal
        model.modelClass = "LNER, 61' 6\" Gresley Corridor Third, 23864"
        model.number = "23864"
        model.livery = "LNER Teak"
        model.era = .theBigFour
        model.imageData = imageData(named: "R4828")
        models["R4828"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .coach
        model.disposition = .normal
        model.modelClass = "LNER, 61' 6\" Gresley Corridor First, 31885"
        model.number = "31885"
        model.livery = "LNER Teak"
        model.era = .theBigFour
        model.imageData = imageData(named: "R4827")
        models["R4827"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .coach
        model.disposition = .normal
        model.modelClass = "LNER, 61' 6\" Gresley Corridor Composite Brake, 32557"
        model.number = "32557"
        model.livery = "LNER Teak"
        model.era = .theBigFour
        model.imageData = imageData(named: "R4826")
        models["R4826"] = model
        
        member = train.addMember()
        member.model = model
        
        
        purchase = Purchase(context: managedObjectContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3676"
        purchase.catalogDescription = "LNER, A4 Class, 4-6-2, 4468 'Mallard'"
        purchase.price = 246.99
        purchase.condition = .new
        purchases["R3676"] = purchase
        
        model = purchase.addModel()
        model.classification = .locomotive
        model.disposition = .normal
        model.modelClass = "LNER A4 4-6-2"
        model.number = "4468"
        model.name = "Mallard"
        model.livery = "LNER, Garter Blue"
        model.era = .theBigFour
        model.imageData = imageData(named: "R3676")
        models["R3676"] = model
        
        
        purchase = Purchase(context: managedObjectContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3691"
        purchase.catalogDescription = "GWR, Hitachi IEP Bi-Mode Class 800/0, 'Paddington' Livery Five Car Train Pack"
        purchase.price = 519.99
        purchase.condition = .new
        purchases["R3691"] = purchase
        
        train = Train(context: managedObjectContext)
        train.number = "800010"
        trains["800010"] = train
        
        model = purchase.addModel()
        model.classification = .multipleUnit
        model.disposition = .normal
        model.modelClass = "800/0 DPTS"
        model.number = "815010"
        model.name = "Paddington Bear"
        model.era = .currentEra
        model.imageData = imageData(named: "R3691.1")
        models["R3691.1"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .multipleUnit
        model.disposition = .normal
        model.modelClass = "800/0 MC"
        model.number = "814010"
        model.livery = "GWR Green"
        model.era = .currentEra
        model.imageData = imageData(named: "R3691.2")
        models["R3691.2"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .multipleUnit
        model.disposition = .normal
        model.modelClass = "800/0 MS"
        model.number = "813010"
        model.livery = "GWR Green"
        model.era = .currentEra
        model.imageData = imageData(named: "R3691.3")
        models["R3691.3"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .multipleUnit
        model.disposition = .normal
        model.modelClass = "800/0 MS"
        model.number = "812010"
        model.livery = "GWR Green"
        model.era = .currentEra
        model.imageData = imageData(named: "R3691.4")
        models["R3691.4"] = model
        
        member = train.addMember()
        member.model = model
        
        model = purchase.addModel()
        model.classification = .multipleUnit
        model.disposition = .normal
        model.modelClass = "800/0 DPTF"
        model.number = "811010"
        model.name = "Michael Bond"
        model.livery = "GWR Green"
        model.era = .currentEra
        model.imageData = imageData(named: "R3691.5")
        models["R3691.5"] = model
        
        member = train.addMember()
        member.model = model
        
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            preconditionFailure("Unable to save context: \(error.localizedDescription)")
        }
    }
    
    #if os(iOS)
    func imageData(named name: String) -> Data? {
        UIImage(named: name)?.pngData()
    }
    #elseif os(macOS)
    func imageData(named name: String) -> Data? {
        NSImage(named: name)?.pngData()
    }
    #endif
}

let previewContent = PreviewContent()
