//
//  Purchase.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Purchase {
    var priceAsDecimal: Decimal? {
        get { price as Decimal? }
        set { price = newValue as NSDecimalNumber? }
    }
    
    var valuationAsDecimal: Decimal? {
        get { valuation as Decimal? }
        set { valuation = newValue as NSDecimalNumber? }
    }
    
    func addModel() -> Model {
        let model = Model(context: managedObjectContext!)
        model.purchase = self
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
        guard let context = managedObjectContext else { fatalError("No context to make query with") }
        guard let manufacturer = manufacturer, let catalogNumber = catalogNumber, !manufacturer.isEmpty && !catalogNumber.isEmpty else { return nil }

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


        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@ && manufacturer == %@ && catalogNumber BEGINSWITH[c] %@", self, manufacturer, catalogNumberBase)

        let purchases = try context.fetch(fetchRequest)
        if purchases.isEmpty {
            return nil
        }
        
        // Look for exact matches, but also double-check that the "begins with" didn't pick up R3001 for R300 and other errors we don't intend.
        var matches: [Purchase] = []
        var exactOnly = false
        for purchase in purchases {
            if purchase.catalogNumber == catalogNumber {
                if !exactOnly {
                    matches.removeAll()
                    exactOnly = true
                }
                
                matches.append(purchase)
            } else if !exactOnly {
                let suffix = purchase.catalogNumber!.dropFirst(catalogNumberBase.count)
                guard suffix.drop(while: ("A"..."Z").contains).isEmpty || purchase.catalogNumber!.filter({ $0 == "-" }).count > 1 else { continue }

                matches.append(purchase)
            }
            
        }

        return matches.count > 0 ? Set(matches) : nil
    }
    
    func fillFromSimilar() throws -> Bool {
        guard let similarPurchases = try similar() else { return false }
        guard let catalogNumber = catalogNumber else { return false }
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
        let models = self.models!.array as! [Model]
        guard models.count <= 1 else { return exactMatch }
        guard models.first?.classification == nil else { return exactMatch }
        models.first?.delete()

        // This is a weird bit, see what the most frequent number of models is - it should always be the same, but keep our "going for the mode" approach.
        // Right now this simply ignores missing models, or extra models, but keeps looking at the rest of the box rather than excluding the purchase altogether; can change that with the flatMap below to check the count matches, rather than checking against index.
        guard let count = similarPurchases.map({ $0.models!.count }).mostFrequent() else { return exactMatch }
        for index in 0..<count {
            let similarModels = Set(similarPurchases.compactMap({ $0.models!.count > index ? $0.models!.array[index] as? Model : nil }))
            
            let model: Model = addModel()
            let _ = try model.fillFromSimilar(models: similarModels, exactMatch: exactMatch)
        }
        
        return true
    }

    
    static func all(in context: NSManagedObjectContext) throws -> [Purchase] {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "manufacturer", ascending: true),
            NSSortDescriptor(key: "catalogNumber", ascending: true),
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let results = try context.fetch(fetchRequest)
        return results
    }

}

extension Purchase/* : CustomStringConvertible*/ {
    
    override public var description: String {
        [ manufacturer, catalogNumber ].compactMap({ $0 }).filter({ !$0.isEmpty }).joined(separator: " ")
    }
    
}
