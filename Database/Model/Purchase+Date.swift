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
}
