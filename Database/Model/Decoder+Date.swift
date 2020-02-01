//
//  Decoder+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Decoder {
    /// Formatter for date types.
    public var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `firmwareDate` as `Date` in current time zone.
    public var firmwareDateAsDate: Date? {
        get { firmwareDate.flatMap { Calendar.current.date(from: $0) } }
        set {
            firmwareDate = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `firmwareDate` formatted as string using `dateFormatter`.
    public var firmwareDateAsString: String? {
        get { firmwareDateAsDate.map { dateFormatter.string(from: $0) } }
        set { firmwareDateAsDate = newValue.flatMap { dateFormatter.date(from: $0) } }
    }
}
