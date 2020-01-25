//
//  EnumComboBoxDataSource.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import AppKit

protocol EnumForDataSource {
    
    var count: Int { get }
    
    func item(at index: Int) -> Any?
    func index(of string: String) -> Int
    func completedString(_ string: String) -> String?
    func string(for object: Any?) -> String?
    func object(for string: String, valid: inout Bool) -> AnyObject?
    
}

struct WrappedEnumForDataSource<T> : EnumForDataSource
    where T : RawRepresentable & CaseIterable & CustomStringConvertible & ConvertibleFromString,
        T.RawValue == Int16
{
    
    //    // HACK: NSComboBox gets very grumpy for some reason if we don't return the exact same object each time; but only in this combo box.
    //    var cache: [ModelEra: NSArray] = [:]
    //
    //    func cached(_ modelEra: ModelEra) -> NSArray {
    //        if let cached = cache[modelEra] {
    //            return cached
    //        } else {
    //            cache[modelEra] = NSArray(object: modelEra)
    //            return cache[modelEra]!
    //        }
    //    }
    
    var count: Int {
        return T.allCases.count
    }
    
    func item(at index: Int) -> Any? {
        return NSArray(object: T(rawValue: T.RawValue(index) + 1)!)
    }
    
    func index(of string: String) -> Int {
        return T(describedBy: string).map({ Int($0.rawValue) - 1 }) ?? NSNotFound
    }
    
    func completedString(_ string: String) -> String? {
        return T.allCases.first(where: { $0.description.lowercased().starts(with: string.lowercased()) })?.description
    }
    
    func string(for object: Any?) -> String? {
        return (object as? [T])?.first?.description
    }
    
    func object(for string: String, valid: inout Bool) -> AnyObject? {
        if let value = T(describedBy: string) {
            // Boxing the struct inside an NSArray allows us to use it here where AnyObject is expected.
            valid = true
            return NSArray(object: value)
        } else if string.isEmpty {
            valid = true
            return nil
        } else {
            valid = false
            return nil
        }
    }
    
}

@objc
class EnumComboBoxDataSource : Formatter, NSComboBoxDataSource {
    
    var wrappedEnum: EnumForDataSource
    
    required init(wrapped: EnumForDataSource) {
        wrappedEnum = wrapped
        super.init()
    }
    
    convenience init<T>(wrapping: T.Type)
        where T : RawRepresentable & CaseIterable & CustomStringConvertible & ConvertibleFromString,
        T.RawValue == Int16 {
            
            let wrapped = WrappedEnumForDataSource<T>()
            self.init(wrapped: wrapped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return wrappedEnum.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return wrappedEnum.item(at: index)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return wrappedEnum.index(of: string)
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        return wrappedEnum.completedString(string)
    }
    
    override func string(for obj: Any?) -> String? {
        return wrappedEnum.string(for: obj)
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        var valid = false
        let object = wrappedEnum.object(for: string, valid: &valid)
        
        if valid {
            obj?.pointee = object
            return true
        } else {
            return false
        }
    }
    
}

