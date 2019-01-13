//
//  Purchase+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {

    /// `date` as `Date` in current time zone.
    public var dateAsDate: Date? {
        return date.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }
    }

    /// `date` formatted as string with format "ddMMyyyy".
    public var dateAsString: String? {
        return dateAsDate.flatMap {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")

            return formatter.string(from: $0)
        }
    }

    /// `dateForGrouping` formatted as string with format "MMMMyyyy".
    public var dateForGroupingAsString: String? {
        guard let _ = date, let dateForGrouping = dateForGrouping else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")

        return formatter.string(from: dateForGrouping)
    }
    
    /// Update the sortable date fields.
    ///
    /// These are stored with the UTC equivalent of midnight at the date, and at the first day
    /// of the month, respectively.
    func updateDateForSort() {
        guard var dateComponents = date as DateComponents? else {
            if self.dateForSort != Date.distantPast { self.dateForSort = Date.distantPast }
            if self.dateForGrouping != Date.distantPast { self.dateForGrouping = Date.distantPast }
            return
        }

        let calendar = dateComponents.calendar ?? Calendar.current
        dateComponents.timeZone = TimeZone(abbreviation: "UTC")!

        let dateForSort = calendar.date(from: dateComponents)
        if self.dateForSort != dateForSort { self.dateForSort = dateForSort }

        dateComponents.day = 1
        let dateForGrouping = calendar.date(from: dateComponents)
        if self.dateForGrouping != dateForGrouping { self.dateForGrouping = dateForGrouping }
    }

}
