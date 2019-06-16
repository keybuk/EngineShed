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
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return formatter
    }

    /// `date` as `Date` in current time zone.
    var dateAsDate: Date? {
        get {
            return date.flatMap { dateComponents -> Date? in
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
        get {
            return dateAsDate.flatMap { return dateFormatter.string(from: $0) }
        }

        set {
            dateAsDate = newValue.flatMap { dateFormatter.date(from: $0) }
        }
    }

    /// `dateForGrouping` formatted as string with format "MMMMyyyy".
    var dateForGroupingAsString: String? {
        guard let _ = date, let dateForGrouping = dateForGrouping else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
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

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        let dateForSort = calendar.date(from: dateComponents)
        if self.dateForSort != dateForSort { self.dateForSort = dateForSort }

        dateComponents.day = 1
        let dateForGrouping = calendar.date(from: dateComponents)
        if self.dateForGrouping != dateForGrouping { self.dateForGrouping = dateForGrouping }
    }

}
