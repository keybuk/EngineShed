//
//  DateMigrationPolicy.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/25/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

@objc
final class DateMigrationPolicy: NSEntityMigrationPolicy {

    @objc
    func dateComponentsFromDate(_ date: Date?) -> DateComponents? {
        guard let date = date else { return nil }
        
        let calendar = Calendar(identifier: .gregorian)

        var calendarInUTC = calendar
        calendarInUTC.timeZone = TimeZone(secondsFromGMT: 0)!

        return calendarInUTC.dateComponents([ .year, .month, .day ], from: date)
    }

}
