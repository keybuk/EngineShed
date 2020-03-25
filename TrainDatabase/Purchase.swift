//
//  Purchase.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Purchase {
    func sortedValuesForManufacturer(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "manufacturer", ascending: true, startingWith: string)
    }

    func sortedValuesForStore(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "store", ascending: true, startingWith: string)
    }
    
    func fillFromSimilar() throws -> Bool {
        let similarPurchases = similar()
        guard !similarPurchases.isEmpty else { return false }
        guard let catalogNumber = catalogNumber else { return false }
        let exactMatch = similarPurchases.first?.catalogNumber == catalogNumber
        
        // For exact match purchases, we copy the product particulars over. Otherwise we assume an A-Z variant will have a different catalog year, as well as a different description (because of the number), etc. so we actually copy none of the product information over in that case.
        if exactMatch {
            if let catalogDescription = similarPurchases.map(\.catalogDescription).mostFrequent() { self.catalogDescription = catalogDescription }
            if let catalogYear = similarPurchases.map(\.catalogYear).mostFrequent() { self.catalogYear = catalogYear }
            if let limitedEdition = similarPurchases.map(\.limitedEdition).mostFrequent() { self.limitedEdition = limitedEdition }
            // limitedEditionNumber is omitted because that should always differ between individual models.
            if let limitedEditionCount = similarPurchases.map(\.limitedEditionCount).mostFrequent() { self.limitedEditionCount = limitedEditionCount }
            if let valuation = similarPurchases.compactMap(\.valuation).mostFrequent() { self.valuation = valuation }
        }
        
        // Don't do model copying if they're already filled out, since we wipe it.
        let models = self.models()
        guard models.count <= 1 else { return exactMatch }
        guard models.first?.classification == nil else { return exactMatch }
        if let existingModel = models.first {
            removeModel(existingModel)
        }

        // This is a weird bit, see what the most frequent number of models is - it should always be the same, but keep our "going for the mode" approach.
        // Right now this simply ignores missing models, or extra models, but keeps looking at the rest of the box rather than excluding the purchase altogether; can change that with the flatMap below to check the count matches, rather than checking against index.
        guard let count = similarPurchases.map({ $0.models!.count }).mostFrequent() else { return exactMatch }
        for index in 0..<count {
            let similarModels = Set<Model>(similarPurchases.compactMap({
                let models = $0.models()
                return models.count > index ? models[index] : nil
            }))
            
            let model: Model = addModel()
            let _ = try model.fillFromSimilar(models: similarModels, exactMatch: exactMatch)
        }
        
        return true
    }

    func models() -> [Model] {
        let fetchRequest = fetchRequestForModels()

        let results = try! managedObjectContext!.fetch(fetchRequest)
        return results
    }

}

extension Purchase/* : CustomStringConvertible*/ {
    
    override public var description: String {
        [ manufacturer, catalogNumber ].compactMap({ $0 }).filter({ !$0.isEmpty }).joined(separator: " ")
    }
    
}
