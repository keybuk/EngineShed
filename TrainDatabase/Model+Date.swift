//
//  Model+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {
    var lastOil: DateComponents? {
        get { managedObject.lastOil }
        set {
            managedObject.lastOil = newValue
            try? managedObject.managedObjectContext?.save() // FIXME!
        }
    }

    /// Formatter for date types.
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `lastOil` as `Date` in current time zone.
    var lastOilAsDate: Date? {
        get {
            lastOil.flatMap { dateComponents -> Date? in
                let calendar = Calendar.current
                return calendar.date(from: dateComponents)
            }
        }

        set {
            lastOil = newValue.flatMap {
                let calendar = Calendar.current
                return calendar.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `lastOil` formatted as string using `dateFormatter`.
    var lastOilAsString: String? {
        get { lastOilAsDate.flatMap { return dateFormatter.string(from: $0) } }
        set { lastOilAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }

    var lastRun: DateComponents? {
        get { managedObject.lastRun }
        set {
            managedObject.lastRun = newValue
            try? managedObject.managedObjectContext?.save() // FIXME!
        }
    }

    /// `lastRun` as `Date` in current time zone.
    var lastRunAsDate: Date? {
        get {
            lastRun.flatMap { dateComponents -> Date? in
                let calendar = Calendar.current
                return calendar.date(from: dateComponents)
            }
        }

        set {
            lastRun = newValue.flatMap {
                let calendar = Calendar.current
                return calendar.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `lastRun` formatted as string using `dateFormatter`.
    var lastRunAsString: String? {
        get { lastRunAsDate.flatMap { return dateFormatter.string(from: $0) } }
        set { lastRunAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }
}
