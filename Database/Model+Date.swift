//
//  Model+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {

    /// `lastOil` as `Date` in current time zone.
    public var lastOilAsDate: Date? {
        return lastOil.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }
    }

    /// `lastOil` formatted as string with format "ddMMyyyy".
    public var lastOilAsString: String? {
        return lastOilAsDate.flatMap {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")

            return formatter.string(from: $0)
        }
    }

    /// `lastRun` as `Date` in current time zone.
    public var lastRunAsDate: Date? {
        return lastRun.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }
    }

    /// `lastRun` formatted as string with format "ddMMyyyy".
    public var lastRunAsString: String? {
        return lastRunAsDate.flatMap {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")

            return formatter.string(from: $0)
        }
    }

}
