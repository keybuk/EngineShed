//
//  Purchase+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {
    /// Formatter for date types.
    public var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `date` as `Date` in current time zone.
    public var dateAsDate: Date? {
        get { date.flatMap { Calendar.current.date(from: $0) } }
        set {
            date = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `date` formatted as string using `dateFormatter`.
    public var dateAsString: String? {
        get { dateAsDate.map { dateFormatter.string(from: $0) } }
        set { dateAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }

    /// Returns a date value suitable for sorting purchaes.
    ///
    /// - Parameter dateComponents: components of date.
    /// - Returns: a `Date` equivalent to UTC midnight on `dateComponents` or `.distantPast` when
    /// `dateComponents` is `nil`.
    func makeDateForSort(from dateComponents: DateComponents?) -> Date {
        guard let dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        return calendar.date(from: dateComponents)!
    }

    /// Returns a date value suitable for grouping purchaes into months.
    ///
    /// - Parameter dateComponents: components of date.
    /// - Returns: a `Date` equivalent to UTC midnight on the first day of the month in`dateComponents` or
    /// `.distantPast` when `dateComponents` is `nil`.
    func makeDateForGrouping(from dateComponents: DateComponents?) -> Date {
        guard var dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        dateComponents.day = 1
        return calendar.date(from: dateComponents)!
    }

    /// `dateForGrouping` formatted as string with format "MMMMyyyy".
    public var dateForGroupingAsString: String? {
        guard let _ = date, let dateForGrouping = dateForGrouping else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")

        return formatter.string(from: dateForGrouping)
    }
}
