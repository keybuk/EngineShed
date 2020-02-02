//
//  DecoderStockTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

@testable import Database

class DecoderStockTests: XCTestCase {
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

    // MARK: DecoderType.isStocked

    /// Check that a decoder type is considered stocked when it has a minimum stock set, even when not stocked.
    func testIsStocked() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStocked, true)
    }

    /// Check that a decoder type is considered stocked when it has remaining stock, even when minimum stock is not set.
    func testRemainingIsStocked() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 0
        decoderType.remainingStock = 5

        XCTAssertEqual(decoderType.isStocked, true)
    }

    /// Check that a decoder type is not considered stocked when we don't have any and don't want any.
    func testIsNotStocked() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 0
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStocked, false)
    }

    // MARK: DecoderType.isStockLow

    /// Check that stock is considered low when the remaining stock is below the minimum stock.
    func testIsStockLow() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 2

        XCTAssertEqual(decoderType.isStockLow, true)
    }

    /// Check that stock is considered low when we're out of stock is below the minimum stock.
    func testOutOfStockIsStockLow() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStockLow, true)
    }

    /// Check that stock is not considered low when the remaining stock is equal to the minimum stock.
    func testIsNotStockLow() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 5

        XCTAssertEqual(decoderType.isStockLow, false)
    }

    /// Check that stock is not considered low when the remaining stock is greater than the minimum stock.
    func testExcessIsNotStockLow() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 11

        XCTAssertEqual(decoderType.isStockLow, false)
    }

    /// Check that stock is not considered low when we have stock of something we wouldn't ordinarily have.
    func testUnstockedIsNotStockLow() {
        let decoderType = DecoderType(context: container!.viewContext)
        decoderType.minimumStock = 0
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStockLow, false)
    }

    // MARK: DecoderType.makeRemainingStock

    /// Check that we correctly calculate the remaining stock ignoring fitted and allocated decoders.
    func testMakeRemainingStock() {
        let decoderType = DecoderType(context: container!.viewContext)

        var decoder = Decoder(context: container!.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: container!.viewContext)
        decoder.model = Model(context: container!.viewContext)
        decoder.model!.purchase = Purchase(context: container!.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: container!.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: container!.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        decoderType.addToDecoders(decoder)

        let remainingStock = decoderType.makeRemainingStock()
        XCTAssertEqual(remainingStock, 2)
    }

    /// Check that we correctly calculate zero when a decoder type has no decoders.
    func testMakeRemainingStockEmpty() {
        let decoderType = DecoderType(context: container!.viewContext)

        let remainingStock = decoderType.makeRemainingStock()
        XCTAssertEqual(remainingStock, 0)
    }

    /// Check that we correctly calculate zero when all decoders are fitted or allocated.
    func testMakeRemainingStockNoSpare() {
        let decoderType = DecoderType(context: container!.viewContext)

        var decoder = Decoder(context: container!.viewContext)
        decoder.model = Model(context: container!.viewContext)
        decoder.model!.purchase = Purchase(context: container!.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: container!.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        decoderType.addToDecoders(decoder)

        let remainingStock = decoderType.makeRemainingStock()
        XCTAssertEqual(remainingStock, 0)
    }

    // MARK: Decoder.isFitted

    /// Check that a decoder is fitted when it has a model set.
    func testIsFitted() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.model = Model(context: container!.viewContext)
        decoder.model!.purchase = Purchase(context: container!.viewContext)

        XCTAssertEqual(decoder.isFitted, true)
    }

    /// Check that a decoder is not fitted when it does not have a model set.
    func testIsNotFitted() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)

        XCTAssertEqual(decoder.isFitted, false)
    }

    // MARK: Decoder.isAllocated

    /// Check that a decoder is allocated when it has a value for sound author.
    func testSoundAuthorIsAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundAuthor = "Legomanbiffo"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound author.
    func testEmptySoundAuthorIsNotAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundAuthor = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has a value for sound project.
    func testSoundProjectIsAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundProject = "Class 68"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound project.
    func testEmptySoundProjectIsNotAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundProject = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has a value for sound project version.
    func testSoundProjectVersionIsAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundProjectVersion = "1.0"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound project version.
    func testEmptySoundProjectVersionIsNotAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundProjectVersion = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has a value for sound settings.
    func testSoundSettingsIsAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundSettings = "Newer Horns (CV43 = 1)"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound settings.
    func testEmptySoundSettingsIsNotAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundSettings = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has complete sound information.
    func testIsAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has no sound information.
    func testIsNotAllocated() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)

        XCTAssertEqual(decoder.isAllocated, false)
    }

    // MARK: Decoder.isSpare

    /// Check that a decoder is spare when it has no model or sound project.
    func testIsSpare() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)

        XCTAssertEqual(decoder.isSpare, true)
    }

    /// Check that a decoder is not spare when it has a model fitted.
    func testFittedIsNotSpare() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.model = Model(context: container!.viewContext)
        decoder.model!.purchase = Purchase(context: container!.viewContext)
        assert(decoder.isFitted)

        XCTAssertEqual(decoder.isSpare, false)
    }

    /// Check that a decoder is not spare when it has a sound project allocated.
    func testAllocatedIsNotSpare() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        assert(decoder.isAllocated)

        XCTAssertEqual(decoder.isSpare, false)
    }

    /// Check that a decoder is not spare when it has a model fitted and sound project allocated.
    func testFittedAndAllocatedIsNotSpare() {
        let decoder = Decoder(context: container!.viewContext)
        decoder.type = DecoderType(context: container!.viewContext)
        decoder.model = Model(context: container!.viewContext)
        decoder.model!.purchase = Purchase(context: container!.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        assert(decoder.isFitted)
        assert(decoder.isAllocated)

        XCTAssertEqual(decoder.isSpare, false)
    }
}
