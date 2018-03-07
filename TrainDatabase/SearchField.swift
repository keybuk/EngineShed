//
//  SearchField.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

enum SearchField : String, Codable, CustomStringConvertible {
    
    case manufacturer // lookup
    case catalogNumber
    case catalogDescription
    case catalogYear
    case limitedEdition
    case limitedEditionNumber
    case limitedEditionCount
    case purchaseDate
    case store // lookup
    case price
    case purchaseCondition
    case valuation
    case purchaseNotes
    
    case classification
    case modelClass
    case number
    case name
    case livery // lookup
    case details
    case era
    case disposition
    
    case trainMember
    case trainPosition
    case train // lookup
    case trainNotes
    
    case motor // lookup
    case lighting
    case socket // lookup
    
    case decoder
    case decoderManufacturer // lookup
    case decoderProductCode
    case decoderProductFamily // lookup
    case decoderSocket // lookup
    case decoderIsProgrammable
    case decoderHasSound
    case decoderHasRailCom
    case decoderSerialNumber
    case decoderFirmwareVersion // lookup
    case decoderFirmwareDate
    case soundAuthor // lookup
    case soundFile
    
    case speaker // lookup
    case speakerFitting
    case couplings
    case features
    case detailParts
    case modifications
    case lastRun
    case lastOil
    case tasks
    case notes
    
    var keyPath: String {
        switch self {
        case .manufacturer: return "purchase.manufacturer"
        case .catalogNumber: return "purchase.catalogNumber"
        case .catalogDescription: return "purchase.catalogDescription"
        case .catalogYear: return "purchase.catalogYear"
        case .limitedEdition: return "purchase.limitedEdition"
        case .limitedEditionNumber: return "purchase.limitedEditionNumber"
        case .limitedEditionCount: return "purchase.limitedEditionCount"
        case .purchaseDate: return "purchase.date"
        case .store: return "purchase.store"
        case .price: return "price"
        case .purchaseCondition: return "purchase.conditionRawValue"
        case .valuation: return "valuation"
        case .purchaseNotes: return "purchase.notes"
        case .classification: return "classificationRawValue"
        case .modelClass: return "modelClass"
        case .number: return "number"
        case .name: return "name"
        case .livery: return "livery"
        case .details: return "details"
        case .era: return "eraRawValue"
        case .disposition: return "dispositionRawValue"
        case .trainMember: return "trainMember"
        case .trainPosition: return "trainMember.title"
        case .train: return "trainMember.train.name"
        case .trainNotes: return "trainMember.train.notes"
        case .motor: return "motor"
        case .lighting: return "lightings"
        case .socket: return "socket"
        case .decoder: return "decoder"
        case .decoderManufacturer: return "decoder.type.manufacturer"
        case .decoderProductCode: return "decoder.type.productCode"
        case .decoderProductFamily: return "decoder.type.productFamily"
        case .decoderSocket: return "decoder.type.socket"
        case .decoderIsProgrammable: return "decoder.type.programmable"
        case .decoderHasSound: return "decoder.type.sound"
        case .decoderHasRailCom: return "decoder.type.railcom"
        case .decoderSerialNumber: return "decoder.serialNumber"
        case .decoderFirmwareVersion: return "decoder.firmwareVersion"
        case .decoderFirmwareDate: return "decoder.firmwareDate"
        case .soundAuthor: return "decoder.soundAuthor"
        case .soundFile: return "decoder.soundFile"
        case .speaker: return "speaker"
        case .speakerFitting: return "speakerFittings"
        case .couplings: return "couplings"
        case .features: return "features"
        case .detailParts: return "detailParts"
        case .modifications: return "modifications"
        case .lastRun: return "lastRun"
        case .lastOil: return "lastOil"
        case .tasks: return "tasks"
        case .notes: return "notes"
        }
    }
    
    var description: String {
        switch self {
        case .manufacturer: return "Manufacturer"
        case .catalogNumber: return "Catalog Number"
        case .catalogDescription: return "Catalog Description"
        case .catalogYear: return "Catalog Year"
        case .limitedEdition: return "Limited Edition"
        case .limitedEditionNumber: return "Limited Edition Number"
        case .limitedEditionCount: return "Limited Edition Count"
        case .purchaseDate: return "Purchase Date"
        case .store: return "Store"
        case .price: return "Purchase Price"
        case .purchaseCondition: return "Purchase Condition"
        case .valuation: return "Valuation"
        case .purchaseNotes: return "Purchase Notes"
        case .classification: return "Classification"
        case .modelClass: return "Class"
        case .number: return "Number"
        case .name: return "Name"
        case .livery: return "Livery"
        case .details: return "Details"
        case .era: return "Era"
        case .disposition: return "Disposition"
        case .trainMember: return "Train Member"
        case .trainPosition: return "Train Position"
        case .train: return "Train"
        case .trainNotes: return "Train Notes"
        case .motor: return "Motor"
        case .lighting: return "Lighting"
        case .socket: return "Socket"
        case .decoder: return "Decoder"
        case .decoderManufacturer: return "Decoder Manufacturer"
        case .decoderProductCode: return "Decoder Product Code"
        case .decoderProductFamily: return "Decoder Product Family"
        case .decoderSocket: return "Decoder Socket"
        case .decoderIsProgrammable: return "Programmable Decoder"
        case .decoderHasSound: return "Sound Decoder"
        case .decoderHasRailCom: return "RailCom Decoder"
        case .decoderSerialNumber: return "Decoder Serial Number"
        case .decoderFirmwareVersion: return "Decoder Firmware Version"
        case .decoderFirmwareDate: return "Decoder Firmware Date"
        case .soundAuthor: return "Sound Author"
        case .soundFile: return "Sound File"
        case .speaker: return "Speaker"
        case .speakerFitting: return "Speaker Fitting"
        case .couplings: return "Couplings"
        case .features: return "Features"
        case .detailParts: return "Detail Parts"
        case .modifications: return "Modifications"
        case .lastRun: return "Last Run"
        case .lastOil: return "Last Oil"
        case .tasks: return "Tasks"
        case .notes: return "Notes"
        }
    }
    
    enum BaseType {
        case none
        case string
        case integer
        case currency
        case date
        case boolean
    }
    
    var baseType: BaseType {
        switch self {
        case .manufacturer: return .string
        case .catalogNumber: return .string
        case .catalogDescription: return .string
        case .catalogYear: return .integer
        case .limitedEdition: return .string
        case .limitedEditionNumber: return .integer
        case .limitedEditionCount: return .integer
        case .purchaseDate: return .date
        case .store: return .string
        case .price: return .currency
        case .purchaseCondition: return .integer // enum
        case .valuation: return .currency
        case .purchaseNotes: return .string
        case .classification: return .integer // enum
        case .modelClass: return .string
        case .number: return .string
        case .name: return .string
        case .livery: return .string
        case .details: return .string
        case .era: return .integer // enum
        case .disposition: return .integer // enum
        case .trainMember: return .none
        case .trainPosition: return .string
        case .train: return .string
        case .trainNotes: return .string
        case .motor: return .string
        case .lighting: return .string // lookup
        case .socket: return .string
        case .decoder: return .none
        case .decoderManufacturer: return .string
        case .decoderProductCode: return .string
        case .decoderProductFamily: return .string
        case .decoderSocket: return .string
        case .decoderIsProgrammable: return .boolean
        case .decoderHasSound: return .boolean
        case .decoderHasRailCom: return .boolean
        case .decoderSerialNumber: return .string
        case .decoderFirmwareVersion: return .string
        case .decoderFirmwareDate: return .date
        case .soundAuthor: return .string
        case .soundFile: return .string
        case .speaker: return .string
        case .speakerFitting: return .string // lookup
        case .couplings: return .string // lookup
        case .features: return .string // lookup
        case .detailParts: return .string // lookup
        case .modifications: return .string // lookup
        case .lastRun: return .date
        case .lastOil: return .date
        case .tasks: return .string // lookup
        case .notes: return .string
        }
    }

}

