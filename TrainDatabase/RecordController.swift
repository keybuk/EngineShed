//
//  RecordController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/2/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Cocoa

import Database

enum CurrentRecord : Equatable {
    
    case model(Model)
    case decoderType(DecoderType)
    
    static func ==(lhs: CurrentRecord, rhs: CurrentRecord) -> Bool {
        switch (lhs, rhs) {
        case let (.model(lhsModel), .model(rhsModel)):
            return lhsModel == rhsModel
        case let (.decoderType(lhsDecoderType), .decoderType(rhsDecoderType)):
            return lhsDecoderType == rhsDecoderType
        default:
            return false
        }
    }
    
}

protocol RecordController : class {
    
    var recordStack: [CurrentRecord] { get set }
    var recordIndex: Int { get set }
    
    var currentRecord: CurrentRecord? { get set }
    
    func recordIndexChanged()
    func currentRecordChanged()

}

extension NSNotification.Name {
    
    static let currentRecordChanged = NSNotification.Name("currentRecordChanged")
    
}

extension RecordController {
    
    var currentRecord: CurrentRecord? {
        get {
            guard !recordStack.isEmpty else { return nil }
            return recordStack[recordIndex]
        }
        
        set {
            guard let newValue = newValue else { fatalError("Current Record cannot be nil") }
            guard currentRecord != newValue else { return }

            let persistentContainer = (NSApplication.shared.delegate! as! AppDelegate).persistentContainer
            let managedObjectContext = persistentContainer.viewContext
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    NSApplication.shared.presentError(error)
                }
            }

            if !recordStack.isEmpty {
                recordStack = Array(recordStack.prefix(through: recordIndex))
                while let index = recordStack.firstIndex(of: newValue) {
                    recordStack.remove(at: index)
                }
            }
            
            recordStack.append(newValue)
            recordIndex = recordStack.index(before: recordStack.endIndex)
            
            recordIndexChanged()
        }
    }
    
}

extension RecordController where Self : NSWindowController {
    
    func recordIndexChanged() {
        currentRecordChanged()
        NotificationCenter.default.post(name: .currentRecordChanged, object: window)
    }

    func currentRecordChanged() {
    }

}

extension NSViewController {
    
    var recordController: RecordController? {
        return view.window?.windowController as? RecordController
    }

}
