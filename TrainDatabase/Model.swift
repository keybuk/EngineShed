//
//  Model.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

struct Model : ManagedObjectBacked {
    
    var managedObject: ModelManagedObject
    
    init(managedObject: ModelManagedObject) {
        self.managedObject = managedObject
    }
    
    init(context: NSManagedObjectContext) {
        managedObject = ModelManagedObject(context: context)
        managedObject.modelClass = ""
        managedObject.number = ""
        managedObject.name = ""
        managedObject.livery = ""
        managedObject.details = ""
        managedObject.motor = ""
        managedObject.socket = ""
        managedObject.speaker = ""
        managedObject.notes = ""
    }

    
    var purchase: Purchase {
        get { return Purchase(managedObject: managedObject.purchase!) }
        set {
            managedObject.purchase = newValue.managedObject
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var trainMember: TrainMember? {
        get { return managedObject.trainMember.map(TrainMember.init(managedObject:)) }
        set {
            managedObject.trainMember = newValue?.managedObject
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var decoder: Decoder? {
        get { return managedObject.decoder.map(Decoder.init(managedObject:)) }
        set {
            managedObject.decoder = newValue?.managedObject
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    
    var classification: ModelClassification? {
        get { return ModelClassification(rawValue: managedObject.classificationRawValue) }
        set {
            managedObject.classificationRawValue = newValue?.rawValue ?? 0
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var modelClass: String {
        get { return managedObject.modelClass ?? "" }
        set {
            managedObject.modelClass = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var imageFilename: String? {
        get { return managedObject.imageFilename }
        set {
            managedObject.imageFilename = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var number: String {
        get { return managedObject.number ?? "" }
        set {
            managedObject.number = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var name: String {
        get { return managedObject.name ?? "" }
        set {
            managedObject.name = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var livery: String {
        get { return managedObject.livery ?? "" }
        set {
            managedObject.livery = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var details: String {
        get { return managedObject.details ?? "" }
        set {
            managedObject.details = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var era: ModelEra? {
        get { return ModelEra(rawValue: managedObject.eraRawValue) }
        set {
            managedObject.eraRawValue = newValue?.rawValue ?? 0
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var disposition: ModelDisposition? {
        get { return ModelDisposition(rawValue: managedObject.dispositionRawValue) }
        set {
            managedObject.dispositionRawValue = newValue?.rawValue ?? 0
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var motor: String {
        get { return managedObject.motor ?? "" }
        set {
            managedObject.motor = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var socket: String {
        get { return managedObject.socket ?? "" }
        set {
            managedObject.socket = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }

    var speaker: String {
        get { return managedObject.speaker ?? "" }
        set {
            managedObject.speaker = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var lastRun: Date? {
        get { return managedObject.lastRun }
        set {
            managedObject.lastRun = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var lastOil: Date? {
        get { return managedObject.lastOil }
        set {
            managedObject.lastOil = newValue
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
    
    
    func updateValues<T>(using entity: T.Type, for key: String, from newValues: Set<String>) where T : NSManagedObject {
        let objects = managedObject.value(forKey: key) as! Set<T>
        for object in objects {
            let objectValue = object.value(forKey: "title") as! String
            if !newValues.contains(objectValue) {
                object.setValue(nil, forKey: "model")
                object.managedObjectContext?.delete(object)
            }
        }
        
        let oldValues = Set(objects.map({ $0.value(forKey: "title") as! String }))
        for newValue in newValues.subtracting(oldValues) {
            let object = T(context: managedObject.managedObjectContext!)
            object.setValue(newValue, forKey: "title")
            object.setValue(managedObject, forKey: "model")
        }
        
        try? managedObject.managedObjectContext?.save()
    }

    var lighting: Set<String> {
        get {
            let objects = managedObject.lightings! as! Set<LightingManagedObject>
            return Set(objects.map({ $0.title! }))
        }
        
        set { updateValues(using: LightingManagedObject.self, for: "lightings", from: newValue) }
    }
    
    var speakerFitting: Set<String> {
        get {
            let objects = managedObject.speakerFittings! as! Set<SpeakerFittingManagedObject>
            return Set(objects.map({ $0.title! }))
        }
        
        set { updateValues(using: SpeakerFittingManagedObject.self, for: "speakerFittings", from: newValue) }
    }

    var couplings: Set<String> {
        get {
            let objects = managedObject.couplings! as! Set<CouplingManagedObject>
            return Set(objects.map({ $0.title! }))
        }
        
        set { updateValues(using: CouplingManagedObject.self, for: "couplings", from: newValue) }
    }

    var features: Set<String> {
        get {
            let objects = managedObject.features! as! Set<FeatureManagedObject>
            return Set(objects.map({ $0.title! }))
        }
        
        set { updateValues(using: FeatureManagedObject.self, for: "features", from: newValue) }
    }

    struct DetailPart : Codable, Equatable, Hashable, Comparable {
        
        var title: String
        var isFitted: Bool = false

        static func ==(lhs: Model.DetailPart, rhs: Model.DetailPart) -> Bool {
            return lhs.title == rhs.title
        }
        
        static func <(lhs: Model.DetailPart, rhs: Model.DetailPart) -> Bool {
            return lhs.title < rhs.title
        }

        var hashValue: Int {
            return title.hashValue
        }
        
    }
    
    var detailParts: Set<DetailPart> {
        get {
            let objects = managedObject.detailParts! as! Set<DetailPartManagedObject>
            return Set(objects.map({ DetailPart(title: $0.title!, isFitted: $0.fitted) }))
        }
        
        set {
            let detailPartObjects = managedObject.detailParts! as! Set<DetailPartManagedObject>
            for detailPartObject in detailPartObjects {
                if let detailPart = newValue.first(where: { $0.title == detailPartObject.title! }) {
                    detailPartObject.fitted = detailPart.isFitted
                } else {
                    detailPartObject.model = nil
                    detailPartObject.managedObjectContext?.delete(detailPartObject)
                }
            }
            
            let oldValues = Set(detailPartObjects.map({ DetailPart(title: $0.title!, isFitted: $0.fitted) }))
            for newValue in newValue.subtracting(oldValues) {
                let detailPartObject = DetailPartManagedObject(context: managedObject.managedObjectContext!)
                detailPartObject.title = newValue.title
                detailPartObject.fitted = newValue.isFitted
                detailPartObject.model = managedObject
            }
            
            try? managedObject.managedObjectContext?.save()
        }
    }

    var modifications: Set<String> {
        get {
            let objects = managedObject.modifications! as! Set<ModificationManagedObject>
            return Set(objects.map({ $0.title! }))
        }
        
        set { updateValues(using: ModificationManagedObject.self, for: "modifications", from: newValue) }
    }

    var tasks: Set<String> {
        get {
            let objects = managedObject.tasks! as! Set<TaskManagedObject>
            return Set(objects.map({ $0.title! }))
        }
        
        set { updateValues(using: TaskManagedObject.self, for: "tasks", from: newValue) }
    }
    
    
    mutating func createDecoderIfNeeded() {
        if decoder == nil {
            decoder = Decoder(context: managedObject.managedObjectContext!)
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    mutating func createTrainMember(in train: Train) {
        trainMember = TrainMember(context: managedObject.managedObjectContext!)
        trainMember?.train = train
        try? managedObject.managedObjectContext?.save()
    }
    
    mutating func createTrain(named name: String) {
        var train = Train(context: managedObject.managedObjectContext!)
        train.name = name
            
        trainMember = TrainMember(context: managedObject.managedObjectContext!)
        trainMember?.train = train
        try? managedObject.managedObjectContext?.save()
    }
    
    func delete() {
        managedObject.managedObjectContext?.delete(managedObject)
        try? managedObject.managedObjectContext?.save()
    }
    
    static let unwantedTasks = [ "Renumber", "Relabel", "Repair" ]

    mutating func addSuggestedTasks() {
        if !motor.isEmpty {
            if decoder == nil {
                tasks.insert("Decoder")
                
                if socket.isEmpty {
                    tasks.insert("DCC Conversion")
                }
            }
            if speaker.isEmpty {
                tasks.insert("Speaker")
            }
            if decoder?.soundFile.isEmpty ?? true {
                tasks.insert("Sound File")
            }
        }
        if !speaker.isEmpty && (decoder?.soundFile.isEmpty ?? true) {
            tasks.insert("Sound File")
        }
        /*if !lighting.isEmpty && decoder == nil {
            tasks.insert("Decoder")
            
            if socket.isEmpty {
                tasks.insert("DCC Conversion")
            }
        }*/
        if !detailParts.filter({ !$0.isFitted }).isEmpty {
            tasks.insert("Detail Parts")
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
    
    
    func sortedValuesForLighting(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: LightingManagedObject.self, for: "title", ascending: true, startingWith: string)
    }
    
    func sortedValuesForSpeakerFitting(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: SpeakerFittingManagedObject.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForCouplings(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: CouplingManagedObject.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForFeatures(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: FeatureManagedObject.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForDetailParts(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: DetailPartManagedObject.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForModifications(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: ModificationManagedObject.self, for: "title", ascending: true, startingWith: string)
    }

    func sortedValuesForTasks(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: TaskManagedObject.self, for: "title", ascending: true, startingWith: string)
    }
    
    
    func sortedValuesForDecoderType(startingWith string: String? = nil) throws -> [DecoderType] {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }

        let fetchRequest: NSFetchRequest<DecoderTypeManagedObject> = DecoderTypeManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "manufacturer", ascending: true),
            NSSortDescriptor(key: "productCode", ascending: true),
            NSSortDescriptor(key: "productFamily", ascending: true),
            NSSortDescriptor(key: "socket", ascending: true)
        ]

        if !socket.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "socket = %@", socket)
        }
        
        let typeObjects = try! context.fetch(fetchRequest)
        return typeObjects.map(DecoderType.init(managedObject:))
    }

    func sortedValuesForDecoder(startingWith string: String? = nil) throws -> [Decoder] {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<DecoderManagedObject> = DecoderManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "serialNumber", ascending: true),
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "serialNumber != ''"))
        predicates.append(NSPredicate(format: "model = NULL OR model = %@", managedObject))

        // If there's already a decoder with a type assigned, limit the serial numbers to the same type.
        // Otherwise limit the serial numbers to those types at least matching the same socket.
        if let decoderType = decoder?.type {
            predicates.append(NSPredicate(format: "type = %@", decoderType.managedObject))
        } else if !socket.isEmpty {
            predicates.append(NSPredicate(format: "type.socket = %@", socket))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let typeObjects = try! context.fetch(fetchRequest)
        return typeObjects.map(Decoder.init(managedObject:))
    }
    
    func sortedValuesForTrain(startingWith string: String? = nil) throws -> [Train] {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<TrainManagedObject> = TrainManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
        ]
        
        fetchRequest.predicate = NSPredicate(format: "name != ''")
        
        let trainObjects = try! context.fetch(fetchRequest)
        return trainObjects.map(Train.init(managedObject:))
    }
    
    
    /// Return a set of similar models.
    ///
    /// Similar models are those which have the same classification and class, from the same manufacturer. e.g. all Bachmann Mk1 BSK coaches would be classified as "similar", but a Mk1 BSK from Hornby would not be, because it's likely to have somewhat different details; also a Mk1 BCK from Bachmann would not be either for the same reason.
    func similar() throws -> Set<Model>? {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<ModelManagedObject> = ModelManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@ && purchase.manufacturer == %@ && classificationRawValue == %d && modelClass == %@", managedObject, purchase.manufacturer, classification?.rawValue ?? 0, modelClass)
        
        let modelObjects = try context.fetch(fetchRequest)
        if modelObjects.isEmpty {
            return nil
        }
        
        let models = modelObjects.map(Model.init(managedObject:))
       
        // Find the models that exist along similar models within the same purchase (multiple units, Class 43, etc. but also box sets).
        // FIXME: since this now behaves like a filter, the != purchase here actually means we DO include models from the current purchase. Handy for BSK-sets, but wrong for 43-sets? Will see over time if this is more annoying than useful.
        let modelsInMultiples = models.reduce(into: [Purchase: [Model]](), { $0[$1.purchase, default: []].append($1) }).filter({ $0.key != purchase && $0.value.count > 1 }).flatMap({ $0.value })

        // Further filter to the set of models within those purchases that are at the same position within the purchase as this model. This should correctly match the front or rear equivalent of a multiple unit, where such things are common.
        let position = purchase.models.index(of: self)
        let equivalentModels = modelsInMultiples.filter({ $0.purchase.models.index(of: $0) == position })
        
        // Add in any model that is not a multiple in a purchase.
        let results = Set(models).subtracting(modelsInMultiples).union(equivalentModels)
        if results.isEmpty {
            return Set(models)
        }
        
        return results
    }
    
    mutating func fillFromSimilar(models purchaseModels: Set<Model>? = nil, exactMatch: Bool = false) throws -> Bool {
        guard let similarModels = try purchaseModels ?? similar() else { return false }

        if exactMatch {
            if let image = similarModels.compactMap({ $0.image }).mostFrequent() { self.image = image }
        }
        if let classification = similarModels.compactMap({ $0.classification }).mostFrequent() { self.classification = classification }
        if let modelClass = similarModels.map({ $0.modelClass }).mostFrequent() { self.modelClass = modelClass }
        if exactMatch {
            if let number = similarModels.map({ $0.number }).mostFrequent() { self.number = number }
            if let name = similarModels.map({ $0.name }).mostFrequent() { self.name = name }
        }
        // These are a bit of a toss-up, right now I think they only make sense to set when we're coming from the same basic catalog range (with an A/B).
        if let _ = purchaseModels {
            if let livery = similarModels.map({ $0.livery }).mostFrequent() { self.livery = livery }
            if let details = similarModels.map({ $0.details }).mostFrequent() { self.details = details }
            if let era = similarModels.compactMap({ $0.era }).mostFrequent() { self.era = era }
        }
        // disposition is omitted because that's chosen on a per-model basis.
        
        if let motor = similarModels.map({ $0.motor }).mostFrequent() { self.motor = motor }
        if let socket = similarModels.map({ $0.socket }).mostFrequent() { self.socket = socket }
        // FIXME: speaker? discuss!
        //if let speaker = similarModels.map({ $0.speaker }).mostFrequent() { model.speaker = speaker }
        // notes, lastRun & lastOil are omitted because they should always differ between individual models.
        // FIXME: some notes should probably be copied.
        
        // For the lists, we look for something slightly different; we look for the values that appear in at least half of the similar models.
        if let lighting = similarModels.flatMap({ $0.lighting }).repeatedValues(atLeast: similarModels.count / 2) { self.lighting = Set(lighting) }
        // FIXME: speakerFitting? discuss!
        //if let speakerFitting = similarModels.flatMap({ $0.speakerFitting }).repeatedValues(atLeast: count / 2) { model.speakerFitting = Set(speakerFitting) }
        if let couplings = similarModels.flatMap({ $0.couplings }).repeatedValues(atLeast: similarModels.count / 2) { self.couplings = Set(couplings) }
        if let features = similarModels.flatMap({ $0.features }).repeatedValues(atLeast: similarModels.count / 2) { self.features = Set(features) }
        // modifications is omitted because that should always differ between individual models.
        
        // detailParts gets copied over with fitted set, which may work, or may not; right now it reflects non-modified state of the world, so it works.
        if let detailParts = similarModels.flatMap({ $0.detailParts }).repeatedValues(atLeast: similarModels.count / 2) { self.detailParts = Set(detailParts) }
        
        // Finally for tasks, there's simply a bunch we don't want to copy over, and some we want to sneak in regardless.
        if let tasks = similarModels.flatMap({ $0.tasks }).filter({ !Model.unwantedTasks.contains($0) }).repeatedValues(atLeast: similarModels.count / 2) { self.tasks = Set(tasks) }
        addSuggestedTasks()

        return true
    }

    
    static func matching(classification: ModelClassification, in context: NSManagedObjectContext) throws -> [Model] {
        let fetchRequest: NSFetchRequest<ModelManagedObject> = ModelManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "classificationRawValue = \(classification.rawValue)")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "modelClass", ascending: true),
            NSSortDescriptor(key: "number", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "dispositionRawValue", ascending: true)
        ]
        
        let modelObjects = try context.fetch(fetchRequest)
        return modelObjects.map(Model.init(managedObject:))
    }
    
    static let searchFields = [ "modelClass", "number", "name", "purchase.catalogNumber", "purchase.catalogDescription", "decoder.serialNumber" ]
    
    static func matching(search: String, in context: NSManagedObjectContext) throws -> [Model] {
        let fetchRequest: NSFetchRequest<ModelManagedObject> = ModelManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "modelClass", ascending: true),
            NSSortDescriptor(key: "number", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "dispositionRawValue", ascending: true)
        ]

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchFields.map({ NSPredicate(format: "\($0) CONTAINS[c] %@", search) }))
        
        let modelObjects = try context.fetch(fetchRequest)
        return modelObjects.map(Model.init(managedObject:))
    }

}

extension Model : CustomStringConvertible {
    
    var description: String {
        return [ modelClass, number, name ].filter({ !$0.isEmpty }).joined(separator: " ")
    }
    
}

extension Model : Encodable {
    
    enum CodingKeys : String, CodingKey {
        case id
        case classification
        case imageFilename
        case modelClass = "class"
        case number
        case name
        case livery
        case details
        case era
        case disposition
        case motor
        case lighting
        case socket
        case speaker
        case speakerFitting
        case couplings
        case features
        case detailParts
        case modifications
        case lastRun
        case lastOil
        case tasks
        case notes
        case trainMemberID
        case decoderID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(managedObject.objectID.uriRepresentation(), forKey: .id)
        try container.encodeIfPresent(classification, forKey: .classification)
        try container.encodeIfPresent(imageFilename, forKey: .imageFilename)
        try container.encode(modelClass, forKey: .modelClass)
        try container.encode(number, forKey: .number)
        try container.encode(name, forKey: .name)
        try container.encode(livery, forKey: .livery)
        try container.encode(details, forKey: .details)
        try container.encodeIfPresent(era, forKey: .era)
        try container.encodeIfPresent(disposition, forKey: .disposition)
        try container.encode(motor, forKey: .motor)
        try container.encode(lighting, forKey: .lighting)
        try container.encode(socket, forKey: .socket)
        try container.encode(speaker, forKey: .speaker)
        try container.encode(speakerFitting, forKey: .speakerFitting)
        try container.encode(couplings, forKey: .couplings)
        try container.encode(features, forKey: .features)
        try container.encode(detailParts, forKey: .detailParts)
        try container.encode(modifications, forKey: .modifications)
        try container.encodeIfPresent(lastRun, forKey: .lastRun)
        try container.encodeIfPresent(lastOil, forKey: .lastOil)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(trainMember?.managedObject.objectID.uriRepresentation(), forKey: .trainMemberID)
        try container.encodeIfPresent(decoder?.managedObject.objectID.uriRepresentation(), forKey: .decoderID)
    }
    
}
