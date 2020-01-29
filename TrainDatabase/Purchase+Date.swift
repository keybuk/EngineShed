//
//  Purchase+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension Purchase {
    /// Formatter for date types.
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `date` as `Date` in current time zone.
    var dateAsDate: Date? {
        get {
            date.flatMap { dateComponents -> Date? in
                let calendar = Calendar.current
                return calendar.date(from: dateComponents)
            }
        }

        set {
            date = newValue.flatMap {
                let calendar = Calendar.current
                return calendar.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `date` formatted as string using `dateFormatter`.
    var dateAsString: String? {
        get { dateAsDate.flatMap { dateFormatter.string(from: $0) } }
        set { dateAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }
}
