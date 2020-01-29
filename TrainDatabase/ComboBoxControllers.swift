//
//  ComboBoxControllers.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/20/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import AppKit

import Database

@objc
class ModelTrainComboBoxController : Formatter, NSComboBoxDataSource {
    
    var trains: [Train]
    
    required init(model: Model) throws {
        trains = try model.sortedValuesForTrain()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return trains.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return NSArray(object: trains[index])
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return trains.firstIndex(where: { $0.name == string }) ?? NSNotFound
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        return trains.first(where: { $0.name?.lowercased().starts(with: string.lowercased()) ?? false })?.name
    }
    
    override func string(for obj: Any?) -> String? {
        if let train = (obj as? [Train])?.first {
            return train.name
        } else {
            return obj as? String
        }
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let train = trains.first(where: { $0.name == string }) {
            // Boxing the struct inside an NSArray allows us to use it here where AnyObject is expected.
            obj?.pointee = NSArray(object: train)
            return true
        } else {
            obj?.pointee = !string.isEmpty ? string as NSString : nil
            return true
        }
    }
    
}

@objc
class DecoderTypeComboBoxController : Formatter, NSComboBoxDataSource {
    
    var decoderTypes: [DecoderType]
    
    required init(model: Model) throws {
        decoderTypes = try model.sortedValuesForDecoderType()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return decoderTypes.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return NSArray(object: decoderTypes[index])
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return decoderTypes.firstIndex(where: { $0.description == string }) ?? NSNotFound
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        return decoderTypes.first(where: { $0.description.lowercased().starts(with: string.lowercased()) })?.description
    }
    
    override func string(for obj: Any?) -> String? {
        return (obj as? [DecoderType])?.first?.description
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let decoderType = decoderTypes.first(where: { $0.description == string }) {
            // Boxing the struct inside an NSArray allows us to use it here where AnyObject is expected.
            obj?.pointee = NSArray(object: decoderType)
            return true
        } else if string.isEmpty {
            obj?.pointee = nil
            return true
        } else {
            return false
        }
    }
    
}

@objc
class DecoderSerialNumberComboBoxController : Formatter, NSComboBoxDataSource {
    
    var decoders: [Decoder]
    
    required init(model: Model) throws {
        decoders = try model.sortedValuesForDecoder()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This isn't supported")
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return decoders.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return NSArray(object: decoders[index])
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return decoders.firstIndex(where: { $0.description == string }) ?? NSNotFound
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        return decoders.first(where: { $0.description.lowercased().starts(with: string.lowercased()) })?.description
    }
    
    override func string(for obj: Any?) -> String? {
        if let decoder = (obj as? [Decoder])?.first {
            return decoder.description
        } else {
            return obj as? String
        }
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let decoder = decoders.first(where: { $0.description == string }) {
            // Boxing the struct inside an NSArray allows us to use it here where AnyObject is expected.
            obj?.pointee = NSArray(object: decoder)
            return true
        } else {
            obj?.pointee = !string.isEmpty ? string as NSString : nil
            return true
        }
    }
    
}

