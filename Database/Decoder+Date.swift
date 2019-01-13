//
//  Decoder+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Decoder {

    /// `firmwareDate` as `Date` in current time zone.
    public var firmwareDateAsDate: Date? {
        return firmwareDate.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }
    }

    /// `firmwareDate` formatted as string with format "ddMMyyyy".
    public var firmwareDateAsString: String? {
        return firmwareDateAsDate.flatMap {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")

            return formatter.string(from: $0)
        }
    }

}
