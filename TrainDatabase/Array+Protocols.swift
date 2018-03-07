//
//  Array+Protocols.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/26/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

extension Array where Element : Hashable {
    
    private var nilIfEmpty : [Element]? {
        return isEmpty ? nil : self
    }
    
    private func countedElements() -> [Element: Int] {
        return reduce(into: [Element: Int](), { $0[$1, default: 0] += 1 })
    }
    
    func mostFrequent() -> Element? {
        return countedElements().max(by: { $0.value < $1.value })?.key
    }
    
    func repeatedValues(atLeast minimum: Int) -> [Element]? {
        return countedElements().filter({ $0.value >= minimum }).map({ $0.key }).nilIfEmpty
    }
    
}

