//
//  Purchase.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

struct Purchase : ManagedObjectBacked {
    
    var managedObject: PurchaseManagedObject

    init(managedObject: PurchaseManagedObject) {
        self.managedObject = managedObject
    }
    
    init(context: NSManagedObjectContext) {
        managedObject = PurchaseManagedObject(context: context)
        managedObject.manufacturer = ""
        managedObject.catalogNumber = ""
        managedObject.catalogDescription = ""
        managedObject.limitedEdition = ""
        managedObject.store = ""
        managedObject.notes = ""
    }
    

    var models: [Model] {
        get {
            let modelObjects = managedObject.models!.array as! [ModelManagedObject]
            return modelObjects.map(Model.init(managedObject:))
        }
        
        set {
            let modelObjects = newValue.map({ $0.managedObject })
            managedObject.models = NSOrderedSet(array: modelObjects)
            try? managedObject.managedObjectContext?.save()
        }
    }
    

    var manufacturer: String {
        get { return managedObject.manufacturer ?? "" }
        set {
            managedObject.manufacturer = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var catalogNumber: String {
        get { return managedObject.catalogNumber ?? "" }
        set {
            managedObject.catalogNumber = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }

    var catalogDescription: String {
        get { return managedObject.catalogDescription ?? "" }
        set {
            managedObject.catalogDescription = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var catalogYear: Int {
        get { return Int(managedObject.catalogYear) }
        set {
            managedObject.catalogYear = Int16(newValue)
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var limitedEdition: String {
        get { return managedObject.limitedEdition ?? "" }
        set {
            managedObject.limitedEdition = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var limitedEditionNumber: Int {
        get { return Int(managedObject.limitedEditionNumber) }
        set {
            managedObject.limitedEditionNumber = Int16(newValue)
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var limitedEditionCount: Int {
        get { return Int(managedObject.limitedEditionCount) }
        set {
            managedObject.limitedEditionCount = Int16(newValue)
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var store: String {
        get { return managedObject.store ?? "" }
        set {
            managedObject.store = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var price: Decimal? {
        get { return managedObject.price as Decimal? }
        set {
            managedObject.price = newValue as NSDecimalNumber?
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var valuation: Decimal? {
        get { return managedObject.valuation as Decimal? }
        set {
            managedObject.valuation = newValue as NSDecimalNumber?
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var notes: String {
        get { return managedObject.notes ?? "" }
        set {
            managedObject.notes = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    
    mutating func addModel() -> Model {
        var model = Model(context: managedObject.managedObjectContext!)
        model.purchase = self
        try? managedObject.managedObjectContext?.save()
        return model
    }
    
    
    func sortedValuesForManufacturer(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "manufacturer", ascending: true, startingWith: string)
    }

    func sortedValuesForStore(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "store", ascending: true, startingWith: string)
    }
    
    
    /// Return a set of similar models.
    ///
    /// A similar purchase is one that has the same manufacturer and catalog number, or the same manufacturer and a catalog number that indicates the same model but with only a running number variation. Where an exact match exists, only those are returned.
    func similar() throws -> Set<Purchase>? {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        guard !manufacturer.isEmpty && !catalogNumber.isEmpty else { return nil }

        var catalogNumberBase = catalogNumber
        if catalogNumberBase.filter({ $0 == "-" }).count > 1 {
            // XX-XX-999Z style (Dapol, Hattons)
            while catalogNumberBase.suffix(1) != "-" {
                catalogNumberBase.removeLast()
            }
        } else {
            // XXXXZ style (Bachmann and Hornby)
            while ("A"..."Z").contains(catalogNumberBase.suffix(1)) {
                catalogNumberBase.removeLast()
            }
        }


        let fetchRequest: NSFetchRequest<PurchaseManagedObject> = PurchaseManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@ && manufacturer == %@ && catalogNumber BEGINSWITH[c] %@", managedObject, manufacturer, catalogNumberBase)

        let purchaseObjects = try context.fetch(fetchRequest)
        if purchaseObjects.isEmpty {
            return nil
        }
        
        // Look for exact matches, but also double-check that the "begins with" didn't pick up R3001 for R300 and other errors we don't intend.
        var matches: [PurchaseManagedObject] = []
        var exactOnly = false
        for purchaseObject in purchaseObjects {
            if purchaseObject.catalogNumber == catalogNumber {
                if !exactOnly {
                    matches.removeAll()
                    exactOnly = true
                }
                
                matches.append(purchaseObject)
            } else if !exactOnly {
                let suffix = purchaseObject.catalogNumber!.dropFirst(catalogNumberBase.count)
                guard suffix.drop(while: ("A"..."Z").contains).isEmpty || purchaseObject.catalogNumber!.filter({ $0 == "-" }).count > 1 else { continue }

                matches.append(purchaseObject)
            }
            
        }

        return matches.count > 0 ? Set(matches.map(Purchase.init(managedObject:))) : nil
    }
    
    mutating func fillFromSimilar() throws -> Bool {
        guard let similarPurchases = try similar() else { return false }
        let exactMatch = similarPurchases.first?.catalogNumber == catalogNumber
        
        // For exact match purchases, we copy the product particulars over. Otherwise we assume an A-Z variant will have a different catalog year, as well as a different description (because of the number), etc. so we actually copy none of the product information over in that case.
        if exactMatch {
            if let catalogDescription = similarPurchases.map({ $0.catalogDescription }).mostFrequent() { self.catalogDescription = catalogDescription }
            if let catalogYear = similarPurchases.map({ $0.catalogYear }).mostFrequent() { self.catalogYear = catalogYear }
            if let limitedEdition = similarPurchases.map({ $0.limitedEdition }).mostFrequent() { self.limitedEdition = limitedEdition }
            // limitedEditionNumber is omitted because that should always differ between individual models.
            if let limitedEditionCount = similarPurchases.map({ $0.limitedEditionCount }).mostFrequent() { self.limitedEditionCount = limitedEditionCount }
            if let valuation = similarPurchases.compactMap({ $0.valuation }).mostFrequent() { self.valuation = valuation }
        }
        
        // Don't do model copying if they're already filled out, since we wipe it.
        guard models.count <= 1 else { return exactMatch }
        guard models.first?.classification == nil else { return exactMatch }
        models.first?.delete()
        
        // This is a weird bit, see what the most frequent number of models is - it should always be the same, but keep our "going for the mode" approach.
        // Right now this simply ignores missing models, or extra models, but keeps looking at the rest of the box rather than excluding the purchase altogether; can change that with the flatMap below to check the count matches, rather than checking against index.
        guard let count = similarPurchases.map({ $0.models.count }).mostFrequent() else { return exactMatch }
        for index in 0..<count {
            let similarModels = Set(similarPurchases.compactMap({ $0.models.count > index ? $0.models[index] : nil }))
            
            var model: Model = addModel()
            let _ = try model.fillFromSimilar(models: similarModels, exactMatch: exactMatch)
        }
        
        return true
    }

    
    static func all(in context: NSManagedObjectContext) throws -> [Purchase] {
        let fetchRequest: NSFetchRequest<PurchaseManagedObject> = PurchaseManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "manufacturer", ascending: true),
            NSSortDescriptor(key: "catalogNumber", ascending: true),
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let purchaseObjects = try context.fetch(fetchRequest)
        return purchaseObjects.map(Purchase.init(managedObject:))
    }

}

extension Purchase : CustomStringConvertible {
    
    var description: String {
        return [ manufacturer, catalogNumber ].filter({ !$0.isEmpty }).joined(separator: " ")
    }
    
}

extension Purchase.Condition: Codable {}

extension Purchase : Encodable {
    
    enum CodingKeys : String, CodingKey {
        case manufacturer
        case catalogNumber
        case catalogDescription
        case catalogYear
        case limitedEdition
        case limitedEditionNumber
        case limitedEditionCount
        case date
        case store
        case price
        case condition
        case valuation
        case notes
        case models
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(catalogNumber, forKey: .catalogNumber)
        try container.encode(catalogDescription, forKey: .catalogDescription)
        try container.encode(catalogYear, forKey: .catalogYear)
        try container.encode(limitedEdition, forKey: .limitedEdition)
        try container.encode(limitedEditionNumber, forKey: .limitedEditionNumber)
        try container.encode(limitedEditionCount, forKey: .limitedEditionCount)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encode(store, forKey: .store)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(condition, forKey: .condition)
        try container.encodeIfPresent(valuation, forKey: .valuation)
        try container.encode(notes, forKey: .notes)
        try container.encode(models, forKey: .models)

    }
    
}

