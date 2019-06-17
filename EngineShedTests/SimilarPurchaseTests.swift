//
//  SimilarPurchaseTests.swift
//  EngineShedTests
//
//  Created by Scott James Remnant on 6/24/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

@testable import EngineShed

class SimilarPurchaseTests : XCTestCase {

    var container: NSPersistentContainer?

    override func setUp() {
        super.setUp()

        container = NSPersistentContainer(name: "EngineShed")
        container!.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container!.loadPersistentStores { (storeDescription, error) in
            XCTAssertNil(error)
        }

        var purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2700"

        purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2700A"

        purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2701"

        purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Not Hornby"
        purchase.catalogNumber = "R2701"

        XCTAssertNoThrow(try container!.viewContext.save())
    }

    override func tearDown() {
        container = nil

        super.tearDown()
    }

    func testExactMatch() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2700"

        let similar = purchase.similar()
        let results = similar.map { $0.manufacturer! + "/" + $0.catalogNumber! }

        XCTAssertEqual(results, [ "Hornby/R2700" ])
    }

    func testExactMatchOfDifferentPrefix() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2700A"

        let similar = purchase.similar()
        let results = similar.map { $0.manufacturer! + "/" + $0.catalogNumber! }

        XCTAssertEqual(results, [ "Hornby/R2700A" ])
    }

    func testInexactMatch() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2700C"

        let similar = purchase.similar()
        let results = Set(similar.map { $0.manufacturer! + "/" + $0.catalogNumber! })

        XCTAssertEqual(results, Set([ "Hornby/R2700", "Hornby/R2700A" ]))
    }

    func testExactMatchRequiresManufacturer() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2701"

        let similar = purchase.similar()
        let results = similar.map { $0.manufacturer! + "/" + $0.catalogNumber! }

        XCTAssertEqual(results, [ "Hornby/R2701" ])
    }

    func testInexactMatchRequiresManufacturer() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2701A"

        let similar = purchase.similar()
        let results = similar.map { $0.manufacturer! + "/" + $0.catalogNumber! }

        XCTAssertEqual(results, [ "Hornby/R2701" ])
    }

    func testIgnoresSavedCatalogNumber() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2700"
        purchase.catalogNumberPrefix = "R2701"

        let similar = purchase.similar()
        let results = similar.map { $0.manufacturer! + "/" + $0.catalogNumber! }

        XCTAssertEqual(results, [ "Hornby/R2700" ])
    }

}
