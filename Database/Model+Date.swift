//
//  Model+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {

    /// Formatter for date types.
    public var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `lastOil` as `Date` in current time zone.
    public var lastOilAsDate: Date? {
        get {
            return lastOil.flatMap { dateComponents -> Date? in
                let calendar = dateComponents.calendar ?? Calendar.current
                return calendar.date(from: dateComponents as DateComponents)
            }
        }

        set {
            lastOil = newValue.flatMap {
                return Calendar.current.dateComponents([ .year, .month, .day ], from: $0) as NSDateComponents?
            }
        }
    }

    /// `lastOil` formatted as string using `dateFormatter`.
    public var lastOilAsString: String? {
        get {
            return lastOilAsDate.flatMap { return dateFormatter.string(from: $0) }
        }

        set {
            lastOilAsDate = newValue.flatMap { dateFormatter.date(from: $0) }
        }
    }

    /// `lastRun` as `Date` in current time zone.
    public var lastRunAsDate: Date? {
        get {
            return lastRun.flatMap { dateComponents -> Date? in
                let calendar = dateComponents.calendar ?? Calendar.current
                return calendar.date(from: dateComponents as DateComponents)
            }
        }

        set {
            lastRun = newValue.flatMap {
                return Calendar.current.dateComponents([ .year, .month, .day ], from: $0) as NSDateComponents?
            }
        }
    }

    /// `lastRun` formatted as string using `dateFormatter`.
    public var lastRunAsString: String? {
        get {
            return lastRunAsDate.flatMap { return dateFormatter.string(from: $0) }
        }

        set {
            lastRunAsDate = newValue.flatMap { dateFormatter.date(from: $0) }
        }
    }

}
