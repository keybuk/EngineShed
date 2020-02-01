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
        get { lastOil.flatMap { Calendar.current.date(from: $0) } }
        set {
            lastOil = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `lastOil` formatted as string using `dateFormatter`.
    public var lastOilAsString: String? {
        get { lastOilAsDate.map { dateFormatter.string(from: $0) } }
        set { lastOilAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }

    /// `lastRun` as `Date` in current time zone.
    public var lastRunAsDate: Date? {
        get { lastRun.flatMap { Calendar.current.date(from: $0) } }
        set {
            lastRun = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `lastRun` formatted as string using `dateFormatter`.
    public var lastRunAsString: String? {
        get { lastRunAsDate.map { dateFormatter.string(from: $0) } }
        set { lastRunAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }
}
