//
//  Model.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Model {
    func getValues<T>(using entity: T.Type, for key: String) -> Set<String> where T : NSManagedObject {
        let objects = value(forKey: key) as! Set<T>
        return Set(objects.map({ $0.value(forKey: "title") as! String }))
    }

    func updateValues<T>(using entity: T.Type, for key: String, from newValues: Set<String>) where T : NSManagedObject {
        let objects = value(forKey: key) as! Set<T>
        for object in objects {
            let objectValue = object.value(forKey: "title") as! String
            if !newValues.contains(objectValue) {
                object.setValue(nil, forKey: "model")
                object.managedObjectContext?.delete(object)
            }
        }
        
        let oldValues = Set(objects.map({ $0.value(forKey: "title") as! String }))
        for newValue in newValues.subtracting(oldValues) {
            let object = T(context: managedObjectContext!)
            object.setValue(newValue, forKey: "title")
            object.setValue(self, forKey: "model")
        }
    }

    var lightsAsStrings: Set<String> {
        get { getValues(using: Light.self, for: "lights") }
        set { updateValues(using: Light.self, for: "lights", from: newValue) }
    }
    
    var speakerFittingsAsStrings: Set<String> {
        get { getValues(using: SpeakerFitting.self, for: "speakerFittings") }
        set { updateValues(using: SpeakerFitting.self, for: "speakerFittings", from: newValue) }
    }

    var couplingsAsStrings: Set<String> {
        get { getValues(using: Coupling.self, for: "couplings") }
        set { updateValues(using: Coupling.self, for: "couplings", from: newValue) }
    }

    var featuresAsStrings: Set<String> {
        get { getValues(using: Feature.self, for: "features") }
        set { updateValues(using: Feature.self, for: "features", from: newValue) }
    }

    var detailPartsAsStrings: Set<String> {
        get { getValues(using: DetailPart.self, for: "detailParts") }
        set { updateValues(using: DetailPart.self, for: "detailParts", from: newValue) }
    }

    func detailPartForTitle(_ title: String) -> DetailPart? {
        (detailParts! as! Set<DetailPart>).first(where: { $0.title == title })
    }

    var detailPartsAsSet: Set<DetailPart> {
        get {
            let objects = detailParts! as! Set<DetailPart>
            return objects
        }
        
        set {
            let detailPartObjects = detailParts! as! Set<DetailPart>
            for detailPartObject in detailPartObjects {
                if let detailPart = newValue.first(where: { $0.title == detailPartObject.title! }) {
                    detailPartObject.isFitted = detailPart.isFitted
                } else {
                    detailPartObject.model = nil
                    detailPartObject.managedObjectContext?.delete(detailPartObject)
                }
            }
            
            let oldValues = detailPartObjects
            for newValue in newValue.subtracting(oldValues) {
                newValue.model = self
            }
        }
    }

    var modificationsAsStrings: Set<String> {
        get { getValues(using: Modification.self, for: "modifications") }
        set { updateValues(using: Modification.self, for: "modifications", from: newValue) }
    }

    var tasksAsStrings: Set<String> {
        get { getValues(using: Task.self, for: "tasks") }
        set { updateValues(using: Task.self, for: "tasks", from: newValue) }
    }

    func createDecoderIfNeeded() {
        if decoder == nil {
            decoder = Decoder(context: managedObjectContext!)
        }
    }
    
    func createTrainMember(in train: Train) {
        trainMember = TrainMember(context: managedObjectContext!)
        trainMember?.train = train
    }
    
    func createTrain(named name: String) {
        let train = Train(context: managedObjectContext!)
        train.name = name
            
        trainMember = TrainMember(context: managedObjectContext!)
        trainMember?.train = train
    }
    
    static let unwantedTasks = [ "Renumber", "Relabel", "Repair" ]

    func addSuggestedTasks() {
        if let motor = motor, !motor.isEmpty {
            if decoder == nil {
                tasksAsStrings.insert("Decoder")
                
                if socket?.isEmpty ?? true {
                    tasksAsStrings.insert("DCC Conversion")
                }
            }
            if speaker?.isEmpty ?? true {
                tasksAsStrings.insert("Speaker")
            }
            if decoder?.soundProject?.isEmpty ?? true {
                tasksAsStrings.insert("Sound File")
            }
        }
        if let speaker = speaker, !speaker.isEmpty && (decoder?.soundProject?.isEmpty ?? true) {
            tasksAsStrings.insert("Sound File")
        }
        /*if !lights.isEmpty && decoder == nil {
            tasks.insert("Decoder")
            
            if socket.isEmpty {
                tasks.insert("DCC Conversion")
            }
        }*/
        if !detailPartsAsSet.filter({ !$0.isFitted }).isEmpty {
            tasksAsStrings.insert("Detail Parts")
        }
    }
    

    func sortedValuesForLivery(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "livery", ascending: true, startingWith: string)
    }

    func sortedValuesForMotor(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "motor", ascending: true, startingWith: string)
    }

    func sortedValuesForSocket(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "socket", ascending: true, startingWith: string)
    }

    func sortedValuesForSpeaker(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "speaker", ascending: true, startingWith: string)
    }
    
    
    func sortedValuesForLights(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: Light.self, for: "title", ascending: true, startingWith: string)
    }
    
    func sortedValuesForSpeakerFitting(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: SpeakerFitting.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForCouplings(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: Coupling.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForFeatures(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: Feature.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForDetailParts(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: DetailPart.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForModifications(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: Modification.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForTasks(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: Task.self, for: "title", ascending: true, startingWith: string)
    }
    
    
    func sortedValuesForDecoderType(startingWith string: String? = nil) throws -> [DecoderType] {
        guard let context = managedObjectContext else { fatalError("No context to make query with") }

        let fetchRequest: NSFetchRequest<DecoderType> = DecoderType.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "manufacturer", ascending: true),
            NSSortDescriptor(key: "productCode", ascending: true),
            NSSortDescriptor(key: "productFamily", ascending: true),
            NSSortDescriptor(key: "socket", ascending: true)
        ]

        if let socket = socket, !socket.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "socket = %@", socket)
        }
        
        let results = try! context.fetch(fetchRequest)
        return results
    }

    func sortedValuesForDecoder(startingWith string: String? = nil) throws -> [Decoder] {
        guard let context = managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<Decoder> = Decoder.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "serialNumber", ascending: true),
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "serialNumber != ''"))
        predicates.append(NSPredicate(format: "model = NULL OR model = %@", self))

        // If there's already a decoder with a type assigned, limit the serial numbers to the same type.
        // Otherwise limit the serial numbers to those types at least matching the same socket.
        if let decoderType = decoder?.type {
            predicates.append(NSPredicate(format: "type = %@", decoderType))
        } else if let socket = socket, !socket.isEmpty {
            predicates.append(NSPredicate(format: "type.socket = %@", socket))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = try! context.fetch(fetchRequest)
        return results
    }
    
    func sortedValuesForTrain(startingWith string: String? = nil) throws -> [Train] {
        guard let context = managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<Train> = Train.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
        ]
        
        fetchRequest.predicate = NSPredicate(format: "name != ''")
        
        let trains = try! context.fetch(fetchRequest)
        return trains
    }
    
    
    /// Return a set of similar models.
    ///
    /// Similar models are those which have the same classification and class, from the same manufacturer. e.g. all Bachmann Mk1 BSK coaches would be classified as "similar", but a Mk1 BSK from Hornby would not be, because it's likely to have somewhat different details; also a Mk1 BCK from Bachmann would not be either for the same reason.
    func similar() throws -> Set<Model>? {
        guard let context = managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@ && purchase.manufacturer == %@ && classificationRawValue == %d && modelClass == %@", self, purchase?.manufacturer ?? "", classification?.rawValue ?? 0, modelClass ?? "")
        
        let models = try context.fetch(fetchRequest)
        if models.isEmpty {
            return nil
        }

        // Find the models that exist along similar models within the same purchase (multiple units, Class 43, etc. but also box sets).
        // FIXME: since this now behaves like a filter, the != purchase here actually means we DO include models from the current purchase. Handy for BSK-sets, but wrong for 43-sets? Will see over time if this is more annoying than useful.
        let modelsInMultiples = models.reduce(into: [Purchase: [Model]](), { $0[$1.purchase!, default: []].append($1) }).filter({ $0.key != purchase && $0.value.count > 1 }).flatMap({ $0.value })

        // Further filter to the set of models within those purchases that are at the same position within the purchase as this model. This should correctly match the front or rear equivalent of a multiple unit, where such things are common.
        let position = purchase!.models().firstIndex(of: self)
        let equivalentModels = modelsInMultiples.filter({ $0.purchase!.models().firstIndex(of: $0) == position })
        
        // Add in any model that is not a multiple in a purchase.
        let results = Set(models).subtracting(modelsInMultiples).union(equivalentModels)
        if results.isEmpty {
            return Set(models)
        }
        
        return results
    }
    
    func fillFromSimilar(models purchaseModels: Set<Model>? = nil, exactMatch: Bool = false) throws -> Bool {
        guard let similarModels = try purchaseModels ?? similar() else { return false }

        if exactMatch {
            if let image = similarModels.compactMap(\.image).mostFrequent() { self.image = image }
        }
        if let classification = similarModels.compactMap(\.classification).mostFrequent() { self.classification = classification }
        if let modelClass = similarModels.map(\.modelClass).mostFrequent() { self.modelClass = modelClass }
        if exactMatch {
            if let number = similarModels.map(\.number).mostFrequent() { self.number = number }
            if let name = similarModels.map(\.name).mostFrequent() { self.name = name }
        }
        // These are a bit of a toss-up, right now I think they only make sense to set when we're coming from the same basic catalog range (with an A/B).
        if let _ = purchaseModels {
            if let livery = similarModels.map(\.livery).mostFrequent() { self.livery = livery }
            if let details = similarModels.map(\.details).mostFrequent() { self.details = details }
            if let era = similarModels.compactMap(\.era).mostFrequent() { self.era = era }
        }
        // disposition is omitted because that's chosen on a per-model basis.
        
        if let motor = similarModels.map(\.motor).mostFrequent() { self.motor = motor }
        if let socket = similarModels.map(\.socket).mostFrequent() { self.socket = socket }
        // FIXME: speaker? discuss!
        //if let speaker = similarModels.map(\.speaker).mostFrequent() { model.speaker = speaker }
        // notes, lastRun & lastOil are omitted because they should always differ between individual models.
        // FIXME: some notes should probably be copied.
        
        // For the lists, we look for something slightly different; we look for the values that appear in at least half of the similar models.
        if let lights = similarModels.flatMap(\.lightsAsStrings).repeatedValues(atLeast: similarModels.count / 2) { self.lightsAsStrings = Set(lights) }
        // FIXME: speakerFitting? discuss!
        //if let speakerFitting = similarModels.flatMap(\.speakerFitting).repeatedValues(atLeast: count / 2) { model.speakerFitting = Set(speakerFitting) }
        if let couplings = similarModels.flatMap(\.couplingsAsStrings).repeatedValues(atLeast: similarModels.count / 2) { self.couplingsAsStrings = Set(couplings) }
        if let features = similarModels.flatMap(\.featuresAsStrings).repeatedValues(atLeast: similarModels.count / 2) { self.featuresAsStrings = Set(features) }
        // modifications is omitted because that should always differ between individual models.
        
        // detailParts gets copied over with isFitted set, which may work, or may not; right now it reflects non-modified state of the world, so it works.
        if let detailParts = similarModels.flatMap(\.detailPartsAsSet).repeatedValues(atLeast: similarModels.count / 2) { self.detailPartsAsSet = Set(detailParts) }
        
        // Finally for tasks, there's simply a bunch we don't want to copy over, and some we want to sneak in regardless.
        if let tasks = similarModels.flatMap(\.tasksAsStrings).filter({ !Model.unwantedTasks.contains($0) }).repeatedValues(atLeast: similarModels.count / 2) { self.tasksAsStrings = Set(tasks) }
        addSuggestedTasks()

        return true
    }
}

extension Model/* : CustomStringConvertible*/ {
    override public var description: String {
        [ modelClass, number, name ].compactMap({ $0 }).filter({ !$0.isEmpty }).joined(separator: " ")
    }
}
