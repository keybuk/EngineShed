//
//  PreviewData.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

import Database

struct PreviewData {
    let container: NSPersistentContainer

    let purchases: [Purchase]
    let models: [Model]
//    let decoderTypes: [DecoderType]

    init() {
        container = PersistentContainer(name: "EngineShed")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error { fatalError("\(error.localizedDescription)") }
        }

        var purchases: [Purchase] = []
        var models: [Model] = []
//        var decoderTypes: [DecoderType] = []

        var purchase = Purchase(context: container.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3612"
        purchase.date = DateComponents(year: 2018, month: 8, day: 1)
        purchase.store = "Hattons"

        var model = purchase.addModel()
        model.purchase = purchase
        model.classification = .steamLocomotive
        model.image = UIImage(named: "R3612")
        model.modelClass = "LNER Gresley 'A4'"
        model.wheelArrangement = "4-6-2"
        model.number = "4468"
        model.name = "Mallard"
        model.era = .theBigFour
        models.append(model)

        purchases.append(purchase)


        purchase = Purchase(context: container.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R30031"
        purchase.date = DateComponents(year: 2020, month: 6, day: 12)
        purchase.store = "Hattons"
        purchase.priceAsDecimal = 179.99
        purchase.priceCurrency = "GBP"

        model = purchase.addModel()
        model.purchase = purchase
        model.classification = .locomotive
        model.image = UIImage(named: "R30031")
        model.modelClass = "Class 87"
        model.wheelArrangement = "Bo-Bo"
        model.number = "87009"
        model.name = "City of Birmingham"
        model.era = .brCorporateBluePostTOPS
        models.append(model)

        purchases.append(purchase)


        purchase = Purchase(context: container.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3742F"
        purchase.date = DateComponents(year: 2020, month: 6, day: 12)
        purchase.priceAsDecimal = 109.99
        purchase.priceCurrency = "GBP"
        purchase.store = "Hattons"

        model = purchase.addModel()
        model.purchase = purchase
        model.classification = .locomotive
        model.image = UIImage(named: "R3742F")
        model.modelClass = "Class 92"
        model.wheelArrangement = "Co-Co"
        model.number = "91 53 0 472 001-3"
        model.name = "Mihai Eminescu"
        model.era = .rebuildingOfTheRailways
        models.append(model)

        purchases.append(purchase)



        /*
        var decoderType = DecoderType(context: container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.productCode = "58429"
        decoderType.productFamily = "LokSound 5 DCC"
        decoderType.socket = "21MTC"
        decoderType.minimumStock = 5
        decoderTypes.append(decoderType)

        decoderType = DecoderType(context: container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.productCode = "58420"
        decoderType.productFamily = "LokSound 5 DCC"
        decoderType.socket = "8-pin NEM652"
        decoderType.minimumStock = 5

        for _ in 0..<10 {
            let decoder = Decoder(context: container.viewContext)
            decoderType.addDecoder(decoder)
        }

        decoderTypes.append(decoderType)

        decoderType = DecoderType(context: container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.productCode = "58828"
        decoderType.productFamily = "LokSound 5 micro DCC"
        decoderType.socket = "Next18"
        decoderType.minimumStock = 0
        decoderTypes.append(decoderType)

        do {
            try container.viewContext.save()
        } catch {
            fatalError("\(error.localizedDescription)")
        }
         */

        self.purchases = purchases
        self.models = models
        //self.decoderTypes = decoderTypes
    }

}

let previewData = PreviewData()
