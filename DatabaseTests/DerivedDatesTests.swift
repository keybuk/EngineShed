//
//  DerivedDatesTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

@testable import Database

class DerivedDatesTests: XCTestCase {
    var container: NSPersistentContainer?

    override func setUp() {
        super.setUp()

        container = NSPersistentContainer(name: "EngineShed", managedObjectModel: PersistentContainer.shared.managedObjectModel)
        container?.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container?.loadPersistentStores { (storeDescription, error) in
            XCTAssertNil(error)
        }
    }

    override func tearDown() {
        container = nil

        super.tearDown()
    }

    // MARK: dateForSort

    /// Check that we convert a date components to the UTC midnight.
    func testDateForSort() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.date = DateComponents(year: 2005, month: 7, day: 18)

        let dateForSort = purchase.makeDateForSort(from: purchase.date!)
        XCTAssertEqual(dateForSort.timeIntervalSince1970, 1121644800)
    }

    /// Check that we convert `nil` to `.distantPast`
    func testNilDateForSort() {
        let purchase = Purchase(context: container!.viewContext)

        let dateForSort = purchase.makeDateForSort(from: nil)
        XCTAssertEqual(dateForSort, .distantPast)
    }

    // MARK: dateForGrouping

    /// Check that we convert a date components to the UTC midnight on the first of the month.
    func testDateForGrouping() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.date = DateComponents(year: 2005, month: 7, day: 18)

        let dateForGrouping = purchase.makeDateForGrouping(from: purchase.date!)
        XCTAssertEqual(dateForGrouping.timeIntervalSince1970, 1120176000)
    }

    /// Check that we convert `nil` to `.distantPast`
    func testNilDateForGrouping() {
        let purchase = Purchase(context: container!.viewContext)

        let dateForGrouping = purchase.makeDateForGrouping(from: nil)
        XCTAssertEqual(dateForGrouping, .distantPast)
    }

    // MARK: dateForGroupingAsString
    
    /// Check that a `dateForGroupingAsString` represents the current date.
    func testDateForGroupingAsString() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.date = DateComponents(year: 2005, month: 7, day: 18)
        purchase.dateForGrouping = purchase.makeDateForGrouping(from: purchase.date!)

        XCTAssertEqual(purchase.dateForGroupingAsString, "July 2005")
    }

    /// Check that `nil` in the `date` means `dateForGroupingAsString` returns `nil` rather than the distant past.
    func testNilDateForGroupingAsString() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.date = nil
        purchase.dateForGrouping = purchase.makeDateForGrouping(from: purchase.date)
        assert(purchase.dateForGrouping != nil)

        XCTAssertNil(purchase.dateForGroupingAsString)
    }

}
