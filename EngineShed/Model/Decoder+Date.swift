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
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `firmwareDate` as `Date` in current time zone.
    var firmwareDateAsDate: Date? {
        get {
            return firmwareDate.flatMap { dateComponents -> Date? in
                let calendar = Calendar.current
                return calendar.date(from: dateComponents)
            }
        }

        set {
            firmwareDate = newValue.flatMap {
                let calendar = Calendar.current
                return calendar.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `firmwareDate` formatted as string using `dateFormatter`.
    var firmwareDateAsString: String? {
        get {
            return firmwareDateAsDate.flatMap { return dateFormatter.string(from: $0) }
        }

        set {
            firmwareDateAsDate = newValue.flatMap { dateFormatter.date(from: $0) }
        }
    }

}
