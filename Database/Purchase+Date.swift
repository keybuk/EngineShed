//
//  Purchase+Date.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {

    /// Purchase date in current time zone.
    public var date: Date? {
        return dateComponents.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }
    }

    /// Formatted date purchased.
    public var dateAsString: String? {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")

        return date.flatMap { formatter.string(from: $0) }
    }

    /// Formatted date for grouping.
    public var dateForGroupingAsString: String? {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")

        return dateForGrouping.flatMap { formatter.string(from: $0) }
    }
    
    /// Update the sortable date fields.
    ///
    /// These are stored with the UTC equivalent of midnight at the date, and at the first day
    /// of the month, respectively.
    func updateDateForSort() {
        guard var dateComponents = dateComponents as DateComponents? else {
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
