//
//  SimilarPurchaseTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/24/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

@testable import Database

class SimilarPurchaseTests : XCTestCase {

    var container: NSPersistentContainer?

    override func setUp() {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container = NSPersistentContainer(name: "EngineShed", managedObjectModel: NSManagedObjectModel.mergedModel(from: Bundle.allBundles)!)
        container?.persistentStoreDescriptions = [description]
        container?.loadPersistentStores { (storeDescription, error) in
            precondition(storeDescription.type == NSInMemoryStoreType)

            if let error = error {
                fatalError("Couldn't create memory context: \(error)")
            }
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

        try! container!.viewContext.save()
    }

    override func tearDown() {
        container = nil
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
