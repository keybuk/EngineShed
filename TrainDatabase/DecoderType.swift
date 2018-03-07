//
//  DecoderType.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

struct DecoderType : ManagedObjectBacked {
    
    var managedObject: DecoderTypeManagedObject
    
    init(managedObject: DecoderTypeManagedObject) {
        self.managedObject = managedObject
    }

    init(context: NSManagedObjectContext) {
        managedObject = DecoderTypeManagedObject(context: context)
        managedObject.manufacturer = ""
        managedObject.productCode = ""
        managedObject.productFamily = ""
        managedObject.productDescription = ""
        managedObject.socket = ""
    }

    
    var decoders: Set<Decoder> {
        get {
            let decoderObjects = managedObject.decoders! as! Set<DecoderManagedObject>
            return Set(decoderObjects.map(Decoder.init(managedObject:)))
        }
        
        set {
            let decoderObjects = newValue.map({ $0.managedObject })
            managedObject.decoders = Set(decoderObjects) as NSSet
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
    
    var productCode: String {
        get { return managedObject.productCode ?? "" }
        set {
            managedObject.productCode = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var productFamily: String {
        get { return managedObject.productFamily ?? "" }
        set {
            managedObject.productFamily = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var productDescription: String {
        get { return managedObject.productDescription ?? "" }
        set {
            managedObject.productDescription = newValue
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
    
    var isProgrammable: Bool {
        get { return managedObject.programmable }
        set {
            managedObject.programmable = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var hasSound: Bool {
        get { return managedObject.sound }
        set {
            managedObject.sound = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var hasRailCom: Bool {
        get { return managedObject.railCom }
        set {
            managedObject.railCom = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var minimumStock: Int {
        get { return Int(managedObject.minimumStock) }
        set {
            managedObject.minimumStock = Int16(newValue)
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    
    mutating func addDecoder() -> Decoder {
        var decoder = Decoder(context: managedObject.managedObjectContext!)
        decoder.type = self
        try? managedObject.managedObjectContext?.save()
        return decoder
    }
    
    
    func sortedValuesForManufacturer(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "manufacturer", ascending: true, startingWith: string)
    }

    func sortedValuesForProductFamily(startingWith string: String? = nil) throws -> [String] {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DecoderTypeManagedObject.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ "productFamily" ]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "productFamily", ascending: true),
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "productFamily != ''"))
        
        if !manufacturer.isEmpty {
            predicates.append(NSPredicate(format: "manufacturer = %@", manufacturer))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try context.fetch(fetchRequest) as! [[String: String]]
        return results.map({ $0["productFamily"]! })
    }

    func sortedValuesForSocket(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "socket", ascending: true, startingWith: string)
    }
    
    
    func unallocatedDecoders() -> Set<Decoder> {
        return decoders.filter({ $0.model == nil })
    }
    
    func spareDecoderCount() -> Int {
        return decoders.filter({ $0.model == nil && $0.soundAuthor.isEmpty && $0.soundFile.isEmpty }).count
    }
    
    
    static func all(in context: NSManagedObjectContext) throws -> [DecoderType] {
        let fetchRequest: NSFetchRequest<DecoderTypeManagedObject> = DecoderTypeManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "manufacturer", ascending: true),
            NSSortDescriptor(key: "productCode", ascending: true)
        ]
        
        let typeObjects = try context.fetch(fetchRequest)
        return typeObjects.map(DecoderType.init(managedObject:))
    }

}


extension DecoderType : CustomStringConvertible {
    
    var description: String {
        let description = [ manufacturer, productCode, productFamily ].filter({ !$0.isEmpty }).joined(separator: " ")
        return socket.isEmpty ? description : description + " (\(socket))"
    }
    
}

extension DecoderType : Encodable {
    
    enum CodingKeys : String, CodingKey {
        case manufacturer
        case productCode
        case productFamily
        case productDescription
        case socket
        case isProgrammable
        case hasSound
        case hasRailCom
        case minimumStock
        case decoders
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(productCode, forKey: .productCode)
        try container.encode(productFamily, forKey: .productFamily)
        try container.encode(productDescription, forKey: .productDescription)
        try container.encode(socket, forKey: .socket)
        try container.encode(isProgrammable, forKey: .isProgrammable)
        try container.encode(hasSound, forKey: .hasSound)
        try container.encode(hasRailCom, forKey: .hasRailCom)
        try container.encode(minimumStock, forKey: .minimumStock)
        try container.encode(decoders, forKey: .decoders)
    }
    
}
