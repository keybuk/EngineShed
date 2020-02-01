//
//  Purchase+Derived.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/25/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

import Database

extension Purchase {
    func makeDateForSort(from dateComponents: DateComponents?) -> Date {
        guard let dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        return calendar.date(from: dateComponents)!
    }

    func makeDateForGrouping(from dateComponents: DateComponents?) -> Date {
        guard var dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        dateComponents.day = 1
        return calendar.date(from: dateComponents)!
    }

    public override func willSave() {
        let newCatalogNumberPrefix = makeCatalogNumberPrefix(from: catalogNumber ?? "")
        if catalogNumberPrefix != newCatalogNumberPrefix { catalogNumberPrefix = newCatalogNumberPrefix }

        let newDateForSort = makeDateForSort(from: date)
        if dateForSort != newDateForSort { dateForSort = newDateForSort }

        let newDateForGrouping = makeDateForGrouping(from: date)
        if dateForGrouping != newDateForGrouping { dateForGrouping = newDateForGrouping }
    }
}
