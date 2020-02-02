//
//  DecoderType+Stock.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension DecoderType {
    /// `minimumStock` formatted as string.
    public var minimumStockAsString: String? {
        get {
            if minimumStock == 0 { return nil }
            return String(minimumStock)
        }
        set { minimumStock = newValue.flatMap { Int16($0) } ?? 0 }
    }

    /// `remainingStock` formatted as string.
    public var remainingStockAsString: String { String(remainingStock) }

    /// Returns `true` if this type of decoder is currently or typically stocked.
    public var isStocked: Bool { minimumStock > 0 || remainingStock > 0 }

    /// Returns `true` if `remainingStock` falls below `minimumStock`.
    public var isStockLow: Bool { minimumStock > 0 && remainingStock < minimumStock }

    /// Returns the number of spare decoders in stock.
    func makeRemainingStock() -> Int16 {
        guard let managedObjectContext = managedObjectContext else { return 0 }

        let fetchRequest = fetchRequestForDecoders(includingFitted: false, includingAllocated: false)

        var count: Int = 0
        managedObjectContext.performAndWait {
            do {
                count = try managedObjectContext.count(for: fetchRequest)
            } catch let error as NSError {
                print("Fetch request failed making remainingStock: \(error.localizedDescription)")
            }
        }
        return Int16(clamping: count)
    }
}
