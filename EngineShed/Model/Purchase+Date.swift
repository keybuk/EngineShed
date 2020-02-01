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
