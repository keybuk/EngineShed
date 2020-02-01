//
//  CatalogNumberPrefixTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/24/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

@testable import Database

class CatalogNumberPrefixTests: XCTestCase {
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

    // MARK: Hornby

    /// Check that a basic Hornby R2702 number isn't modified.
    func testHornby() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2702"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "R2702")
    }

    /// Check that an old three-digit Hornby number isn't modified.
    func testOldHornby() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R296"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "R296")
    }

    /// Check that a Hornby additional running number loses the suffix letter.
    func testHornbyRunningNumber() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R2290D"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "R2290")
    }

    /// Check that a Hornby TTS number loses the TTS suffix.
    func testHornbyTTS() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3390TTS"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "R3390")
    }

    // MARK: Bachmann

    /// Check that a basic Bachmann 31-654 number isn't modified.
    func testBachmann() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Bachmann"
        purchase.catalogNumber = "31-654"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "31-654")
    }

    /// Check that a Bachmann additional running number loses the suffix.
    func testBachmannRunningNumber() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Bachmann"
        purchase.catalogNumber = "32-452A"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "32-452")
    }

    /// Check that a Bachmann special edition loses the Z suffix.
    func testBachmannSpecialEdition() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Bachmann"
        purchase.catalogNumber = "31-657Z"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "31-657")
    }

    /// Check that a Bachmann South West Digital special edition loses the QDS suffix.
    func testBachmannSWD() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Bachmann"
        purchase.catalogNumber = "31-650QDS"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "31-650")
    }

    // MARK: Dapol

    /// Check that a Dapol 4D-022-000 number has the last part removed, but dash preserved.
    func testDapol() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Dapol"
        purchase.catalogNumber = "4D-006-000"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "4D-006-")
    }

    /// Check that a Dapol sound fitted locomotive has the suffix and last number removed.
    func testDapolSound() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Dapol"
        purchase.catalogNumber = "4D-022-001S"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "4D-022-")
    }

    /// Check that a Dapol special edition for Hattons has the whole last part removed.
    func testDapolHattons() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Dapol"
        purchase.catalogNumber = "4D-009-HAT05"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "4D-009-")
    }

    /// Check that a Dapol special edition for DCC Concepts has the whole last part removed.
    func testDapolDCCConcepts() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Dapol"
        purchase.catalogNumber = "4D-009-DCC1"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "4D-009-")
    }

    /// Check that the unusual Gaugemaster special edition numbering is unmodified.
    func testDapolGaugemaster() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Dapol"
        purchase.catalogNumber = "DAGM101"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "DAGM101")
    }

    /// Check that the unusual Olivia's Trains special edition numbering is unmodified.
    func testDapolOlivias() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Dapol"
        purchase.catalogNumber = "OLIV001"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "OLIV001")
    }

    // MARK: Hattons

    /// Check that a Hattons H4-PH-012 number has the last part removed, but dash preserved.
    func testHattons() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Hattons"
        purchase.catalogNumber = "H4-P-012"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "H4-P-")
    }

    // MARK: Realtrack

    /// Check that a Realtrack 143-212 number has the last part removed.
    func testRealtrack() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Realtrack"
        purchase.catalogNumber = "143-212"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "143-")
    }

    // MARK: Oxford Rail/Diecast

    /// Check that an Oxford Rail OR763TO002 number is preserved.
    func testOxford() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Oxford Rail"
        purchase.catalogNumber = "OR763TO002"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "OR763TO002")
    }

    /// Check that an Oxford Rail alternate running number has the letter suffix removed.
    func testOxfordRunningNumber() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Oxford Rail"
        purchase.catalogNumber = "OR763TO002B"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "OR763TO002")
    }

    /// Check that an Oxford Diecast 76CONT001 number is preserved.
    func testOxfordDiecast() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Oxford Diecast"
        purchase.catalogNumber = "76CONT001"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "76CONT001")
    }

    /// Check that an Oxford Diecast 76CONT00124 number has the running number removed.
    func testOxfordDiecastRunningNumber() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Oxford Diecast"
        purchase.catalogNumber = "76CONT00124"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "76CONT001")
    }

    // MARK: Others

    /// Check that a Heljan 3356 number is unmodified.
    func testHeljan() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Heljan"
        purchase.catalogNumber = "3356"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "3356")
    }

    /// Check that a Rapido 13501 number is unmodified.
    func testRapido() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Rapido"
        purchase.catalogNumber = "13501"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "13501")
    }

    /// Check that an all-letters catalog number is unmodified.
    func testAllLetter() {
        let purchase = Purchase(context: container!.viewContext)
        purchase.manufacturer = "Britannia Models"
        purchase.catalogNumber = "GLV"

        let catalogNumberPrefix = purchase.makeCatalogNumberPrefix(from: purchase.catalogNumber!)
        XCTAssertEqual(catalogNumberPrefix, "GLV")
    }
}
