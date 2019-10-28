//
//  Importer.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/13/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

private extension String {
    
    var intValue: Int {
        return NumberFormatter().number(from: self)?.intValue ?? 0
    }

    var boolValue: Bool {
        return NumberFormatter().number(from: self)?.boolValue ?? false
    }
    
    var decimalValue: Decimal? {
        return Decimal(string: self.starts(with: "$") ? String(self.dropFirst()) : self)
    }
    
    var dateValue: Date? {
        // ReleaseDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return dateFormatter.date(from: self)
    }
    
    var purchaseConditionValue: PurchaseCondition? {
        switch self {
        case "1":
            return .handmade
        case "2":
            return .likeNew
        case "3":
            return .new
        case "4":
            return .used
        case "5":
            return .usedInWrongBox
        case "":
            return nil
        default:
            fatalError("Unknown purchase condition: \(self)")
        }
    }
    
    var modelDispositionValue: ModelDisposition? {
        switch self {
        case "1":
            return .normal
        case "2":
            return .collectorItem
        case "3":
            return .spareParts
        case "":
            return nil
        default:
            fatalError("Unknown disposition: \(self)")
        }
    }

    var modelClassificationValue: ModelClassification? {
        switch self {
        case "1":
            return .locomotive
        case "2":
            return .coach
        case "3":
            return .wagon
        case "4":
            return .departmental
        case "5":
            return .noPrototype
        case "6":
            return .multipleUnit
        case "7":
            return .accessory
        case "":
            return nil
        default:
            fatalError("Unknown classification: \(self)")
        }
    }
    
    var modelEraValue: ModelEra? {
        guard let era = NumberFormatter().number(from: self)?.intValue else { return nil }
        return ModelEra(era: era)
    }
    
    func lookup(values: [String: [String: String]]) -> Set<String> {
        var strings: [String] = []
        
        for valueID in self.components(separatedBy: ";") {
            guard let value = values[valueID] else { continue }
            
            strings.append(value["Description"]!)
        }
        
        return Set(strings)
    }
    
}

class Importer {
    
    var directoryURL: URL
    var context: NSManagedObjectContext
    
    init(directory: String, into managedObjectContext: NSManagedObjectContext) {
        self.directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        self.context = managedObjectContext
    }

    func start() {
        let fileManager = FileManager.default
        let modelImagesURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ModelImages", isDirectory: true)
        try! fileManager.createDirectory(at: modelImagesURL, withIntermediateDirectories: true)

        
        let manufacturers = read(filename: "Manufacturer.txt")
        let products = read(filename: "Product.txt")
        let stores = read(filename: "Store.txt")
        let purchases = read(filename: "Purchase.txt")
        
        let decoders = read(filename: "Decoder.txt")
        let decoderProducts = read(filename: "DecoderProduct.txt")
        let decoderFirmwares = read(filename: "DecoderFirmware.txt")
        let soundAuthors = read(filename: "SoundAuthor.txt")

        let items = read(filename: "Item.txt")
        let models = read(filename: "Model.txt")
        
        let liveries = read(filename: "Livery.txt")
        let motors = read(filename: "Motor.txt")
        let sockets = read(filename: "Socket.txt")
        let speakers = read(filename: "Speaker.txt")
        
        let lightings = read(filename: "Lighting.txt")
        let couplings = read(filename: "Coupling.txt")
        let features = read(filename: "Feature.txt")
        let detailParts = read(filename: "DetailPart.txt")
        let speakerFittings = read(filename: "SpeakerFitting.txt")
        let modifications = read(filename: "Modification.txt")
        let tasks = read(filename: "Task.txt")
        
        let trains = read(filename: "Train.txt")
        let trainMembers = read(filename: "TrainMember.txt")
        
        var decoderRecords: [String: Decoder] = [:]
        var modelRecords: [String: Model] = [:]

        for decoderProductID in decoderProducts.keys.sorted() {
            let decoderProduct = decoderProducts[decoderProductID]!
            let manufacturer = manufacturers[decoderProduct["ManufacturerID"]!]
            let socket = sockets[decoderProduct["SocketID"]!]
            
            var typeRecord = DecoderType(context: context)
            typeRecord.manufacturer = manufacturer?["Name"]! ?? ""
            typeRecord.productCode = decoderProduct["ProductCode"]!
            typeRecord.productFamily = decoderProduct["ProductFamily"]!
            typeRecord.productDescription = decoderProduct["Description"]!
            typeRecord.socket = socket?["Name"]! ?? ""
            typeRecord.hasSound = decoderProduct["Sound"]!.boolValue
            typeRecord.hasRailCom = decoderProduct["RailCom"]!.boolValue
            typeRecord.isProgrammable = typeRecord.hasSound || typeRecord.hasRailCom
            typeRecord.minimumStock = decoderProduct["MinimumStock"]!.intValue
            
            //try! typeRecord.validateForInsert()
        
            for (decoderID, decoder) in decoders.filter({ $1["DecoderProductID"]! == decoderProductID }) {
                let decoderFirmware = decoderFirmwares[decoder["DecoderFirmwareID"]!]
                let soundAuthor = soundAuthors[decoder["SoundAuthorID"]!]
                
                var decoderRecord = Decoder(context: context)
                decoderRecord.type = typeRecord
                decoderRecord.serialNumber = decoder["SerialNumber"]!
                decoderRecord.firmwareVersion = decoderFirmware?["Version"]! ?? ""
                decoderRecord.firmwareDate = decoderFirmware?["ReleaseDate"]!.dateValue
                decoderRecord.address = decoder["Address"]!.intValue
                decoderRecord.soundAuthor = soundAuthor?["Name"]! ?? ""
                decoderRecord.soundFile = decoder["SoundFile"]!
                
                //try! decoderRecord.validateForInsert()

                decoderRecords[decoderID] = decoderRecord
            }
        }
        
        for purchaseID in purchases.keys.sorted() {
            let purchase = purchases[purchaseID]!
            let product = products[purchase["ProductID"]!]!
            let manufacturer = manufacturers[product["ManufacturerID"]!]!
            let store = stores[purchase["StoreID"]!]
            
            var purchaseRecord = Purchase(context: context)
            purchaseRecord.manufacturer = manufacturer["Name"]!
            purchaseRecord.catalogNumber = product["CatalogNumber"]!
            purchaseRecord.catalogYear = product["CatalogYear"]!.intValue
            purchaseRecord.catalogDescription = product["Description"]!
            purchaseRecord.limitedEdition = product["LimitedEdition"]!
            purchaseRecord.limitedEditionNumber = purchase["LimitedEditionNumber"]!.intValue
            purchaseRecord.limitedEditionCount = purchase["LimitedEditionCount"]!.intValue
            purchaseRecord.date = purchase["PurchaseDate"]!.dateValue
            purchaseRecord.store = store?["Name"]! ?? ""
            purchaseRecord.price = purchase["Price"]!.decimalValue
            purchaseRecord.condition = purchase["PurchaseConditionID"]!.purchaseConditionValue
            purchaseRecord.valuation = product["Valuation"]!.decimalValue
            purchaseRecord.notes = purchase["Notes"]!
            
            //try! purchaseRecord.validateForInsert()

            for (modelID, model) in models.filter({ $1["PurchaseID"]! == purchaseID }) {
                let item = items[model["ItemID"]!]!
                let livery = liveries[item["LiveryID"]!]
                let motor = motors[item["MotorID"]!]
                let socket = sockets[item["SocketID"]!]
                let speaker = speakers[model["SpeakerID"]!]
                
                var modelRecord = Model(context: context)
                purchaseRecord.models.append(modelRecord)
                
                modelRecord.classification = item["ClassificationID"]!.modelClassificationValue!   // FIXME: enum is not optional
                modelRecord.modelClass = item["Class"]!
                modelRecord.number = item["Number"]!
                modelRecord.name = item["Name"]!
                modelRecord.livery = livery?["Description"]! ?? ""
                modelRecord.details = item["Details"]!
                modelRecord.era = item["EraID"]!.modelEraValue   // FIXME: enum is storing 0 behind the scenes because raw value is not optional
                modelRecord.disposition = model["DispositionID"]!.modelDispositionValue!   // FIXME: enum is not optional
                modelRecord.motor = motor?["Description"]! ?? ""
                modelRecord.socket = socket?["Name"]! ?? ""
                modelRecord.speaker = speaker?["Description"]! ?? ""
                modelRecord.lastRun = model["LastRun"]!.dateValue
                modelRecord.lastOil = model["LastOil"]!.dateValue
                modelRecord.notes = [ item["Notes"]!, model["Notes"]! ].filter({ !$0.isEmpty }).joined(separator: " ")
                
                modelRecord.decoder = decoderRecords[model["DecoderID"]!]
                
                modelRecord.lighting = item["LightingID"]!.lookup(values: lightings)
                modelRecord.couplings = item["CouplingID"]!.lookup(values: couplings)
                modelRecord.features = item["FeatureID"]!.lookup(values: features)
                modelRecord.speakerFitting = model["SpeakerFittingID"]!.lookup(values: speakerFittings)
                modelRecord.modifications = model["ModificationID"]!.lookup(values: modifications)
                modelRecord.tasks = model["TaskID"]!.lookup(values: tasks)

                let optionalDetailParts = Set(item["OptionalDetailPartID"]!.lookup(values: detailParts))
                let fittedDetailParts = Set(item["FittedDetailPartID"]!.lookup(values: detailParts))

                for value in optionalDetailParts.union(fittedDetailParts) {
                    let valueRecord = DetailPartManagedObject(context: context)
                    valueRecord.model = modelRecord.managedObject
                    valueRecord.title = value
                    valueRecord.fitted = fittedDetailParts.contains(value)
                    try! valueRecord.validateForInsert()
                }

                if !item["Image"]!.isEmpty {
                    let sourceImageURL = directoryURL.appendingPathComponent("Images", isDirectory: true).appendingPathComponent(item["Image"]!)
                    modelRecord.imageFilename = UUID().uuidString
                    let modelImageURL = modelImagesURL.appendingPathComponent(modelRecord.imageFilename!)
                    try! fileManager.copyItem(at: sourceImageURL, to: modelImageURL)
                } else {
                    modelRecord.imageFilename = nil
                }

                //try! modelRecord.validateForInsert()
                modelRecords[modelID] = modelRecord
            }
        }

        for trainID in trains.keys.sorted() {
            let train = trains[trainID]!
            
            var trainRecord = Train(context: context)
            trainRecord.name = train["Name"]!
            trainRecord.notes = [ train["Source"]!, train["Description"]! ].filter({ !$0.isEmpty }).joined(separator: " ")
            
            //try! trainRecord.validateForInsert()

            for trainMember in trainMembers.filter({ $1["TrainID"]! == trainID }).values.sorted(by: { $0["Position"]!.intValue < $1["Position"]!.intValue }) {
                var trainMemberRecord = TrainMember(context: context)
                trainRecord.members.append(trainMemberRecord)
                
                trainMemberRecord.title = trainMember["Description"]!
                trainMemberRecord.model = modelRecords[trainMember["ModelID"]!]
                
                //try! trainMemberRecord.validateForInsert()
            }
        }
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                fatalError("Unable to save: \(nserror)")
            }
        }

        print("Saved.")
    }
    
    func read(filename: String) -> [String: [String: String]] {
        let data = try! String(contentsOf: directoryURL.appendingPathComponent(filename))
        
        var fieldTitles: [String] = []
        var values: [String: [String: String]] = [:]
        data.enumerateLines {
            line, stop in
            var fields: [String] = []

            var remainingRange = line.startIndex..<line.endIndex
            line: while true {
                if line[remainingRange].starts(with: "\"") {
                    remainingRange = line.index(after: remainingRange.lowerBound)..<line.endIndex
                    
                    var field = ""
                    while let quoteRange = line.range(of: "\"", options: [], range: remainingRange) {
                        field += line[remainingRange.lowerBound..<quoteRange.lowerBound]
                        remainingRange = quoteRange.upperBound..<line.endIndex
                        
                        if remainingRange.isEmpty {
                            fields.append(field)
                            break line
                        } else if line[remainingRange].starts(with: ",") {
                            fields.append(field)
                            remainingRange = line.index(after: remainingRange.lowerBound)..<line.endIndex
                            break
                        } else if line[remainingRange].starts(with: "\"") {
                            field += "\""
                            remainingRange = line.index(after: remainingRange.lowerBound)..<line.endIndex
                        }
                    }
                } else if let commaRange = line.range(of: ",", options: [], range: remainingRange) {
                    let field = line[remainingRange.lowerBound..<commaRange.lowerBound]
                    fields.append(String(field))
                    remainingRange = commaRange.upperBound..<line.endIndex
                } else {
                    let field = line[remainingRange]
                    fields.append(String(field))
                    break
                }
            }
            
            if fieldTitles.isEmpty {
                fieldTitles = fields
            } else if fields.count != fieldTitles.count {
                fatalError("Line has wrong number of fields \(fields.count) != \(fieldTitles.count): \(fields) \(fieldTitles)")
            } else {
                let lineValues = Dictionary(uniqueKeysWithValues: zip(fieldTitles, fields))
                values[lineValues["ID"]!] = lineValues
            }
        }
        
        return values
    }
    
}
