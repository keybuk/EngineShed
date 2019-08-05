//
//  PreviewData.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

#if DEBUG
import SwiftUI
import CoreData

struct PreviewData {

    let container: NSPersistentContainer

    let purchases: [Purchase]
    let models: [Model]
    let decoderTypes: [DecoderType]

    init() {
        container = NSPersistentContainer(name: "EngineShed")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error { fatalError("\(error.localizedDescription)") }
        }

        var purchases: [Purchase] = []
        var models: [Model] = []
        var decoderTypes: [DecoderType] = []

        var purchase = Purchase(context: container.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3612"
        purchase.date = DateComponents(year: 2018, month: 8, day: 1)
        purchase.store = "Hattons"

        var model = Model(context: container.viewContext)
        model.purchase = purchase
        model.image = UIImage(named: "R3612")
        model.modelClass = "LNER Gresley 'A4' 4-6-2"
        model.number = "4468"
        model.name = "Mallard"
        purchase.addModel(model)
        models.append(model)

        purchases.append(purchase)


        purchase = Purchase(context: container.viewContext)
        purchase.manufacturer = "Locomotion Models"
        purchase.catalogNumber = "R453875"
        purchase.date = DateComponents(year: 2018, month: 12, day: 27)
        purchase.store = "Locomotion Models"

        model = Model(context: container.viewContext)
        model.purchase = purchase
        model.image = UIImage(named: "R3612")
        model.modelClass = "LNER Gresley 'A4' 4-6-2"
        model.number = "4468"
        model.name = "Mallard"
        purchase.addModel(model)

        purchases.append(purchase)


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
            decoder.type = decoderType
            decoderType.addToDecoders(decoder)
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

        self.purchases = purchases
        self.models = models
        self.decoderTypes = decoderTypes
    }

}

let previewData = PreviewData()

#endif
