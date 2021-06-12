//
//  Purchase+WillSave.swift
//  Database
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {
    public override func willSave() {
        let newCatalogNumberPrefix = catalogNumber.map { makeCatalogNumberPrefix(from: $0) }
        if catalogNumberPrefix != newCatalogNumberPrefix { catalogNumberPrefix = newCatalogNumberPrefix }

        let newDateForSort = makeDateForSort(from: date)
        if dateForSort != newDateForSort { dateForSort = newDateForSort }

        let newDateForGrouping = makeDateForGrouping(from: date)
        if dateForGrouping != newDateForGrouping { dateForGrouping = newDateForGrouping }
    }
}
