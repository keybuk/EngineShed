//
//  PurchaseModelsTests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import XCTest
import CoreData

import Database

class PurchaseModelsTests: XCTestCase {
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

    // MARK: addModel

    /// Check that we can add a model to an empty purchase.
    func testAddFirstModel() {
        let purchase = Purchase(context: container!.viewContext)
        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 0)
    }

    /// Check that we can add a second model to a purchase.
    func testAddSecondModel() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 1)

        XCTAssertEqual(models[0].index, 0)
    }

    /// Check that adding a model makes minimal changes to indexes.
    func testAddMinimizesChanges() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        try! container!.viewContext.save()

        let _ = purchase.addModel()

        XCTAssertFalse(models[0].hasChanges)
    }

    // MARK: removeModel

    /// Check that we can remove the only model from a purchase.
    func testRemoveModel() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.removeModel(models[0])

        XCTAssertTrue(models[0].isDeleted)
        XCTAssertNil(models[0].purchase)
        XCTAssertFalse(purchase.models?.contains(models[0]) ?? false)
    }

    /// Check that we can remove a second model from a purchase.
    func testRemoveSecondModel() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 1] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.removeModel(models[1])

        XCTAssertTrue(models[1].isDeleted)
        XCTAssertNil(models[1].purchase)
        XCTAssertFalse(purchase.models?.contains(models[1]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[0]) ?? false)

        XCTAssertEqual(models[0].index, 0)
    }

    /// Check that we can remove the first of two models from a purchase, and the second is reindexed.
    func testRemoveFirstModelOfTwo() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 1] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.removeModel(models[0])

        XCTAssertTrue(models[0].isDeleted)
        XCTAssertNil(models[0].purchase)
        XCTAssertFalse(purchase.models?.contains(models[0]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[1]) ?? false)

        XCTAssertEqual(models[1].index, 0)
    }

    /// Check that we can remove the first of three models from a purchase, and the second and third are reindexed.
    func testRemoveFirstModelOfThree() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 1, 2] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.removeModel(models[0])

        XCTAssertTrue(models[0].isDeleted)
        XCTAssertNil(models[0].purchase)
        XCTAssertFalse(purchase.models?.contains(models[0]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[1]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[2]) ?? false)

        XCTAssertEqual(models[1].index, 0)
        XCTAssertEqual(models[2].index, 1)
    }

    /// Check that removing a model makes minimal changes to indxes.
    func testRemoveMinimxesChanges() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 1] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        try! container!.viewContext.save()

        purchase.removeModel(models[1])

        XCTAssertFalse(models[0].hasChanges)
    }

    // MARK: moveModel

    /// Check that moving a model forwards works.
    func testMoveModelForwards() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(4, to: 2)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 1)
        XCTAssertEqual(models[2].index, 3)
        XCTAssertEqual(models[3].index, 4)
        XCTAssertEqual(models[4].index, 2)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that moving a model backwards works.
    func testMoveModelBackwards() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(1, to: 3)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 3)
        XCTAssertEqual(models[2].index, 1)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that moving a model to its existing location does nothing.
    func testMoveModelToSameModel() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(4, to: 4)

        for (index, model) in models.enumerated() {
            XCTAssertEqual(model.index, Int16(clamping: index))
        }
    }

    /// Check that swapping two models forward in the middle of the set works.
    func testMoveModelSwapForwards() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(2, to: 3)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 1)
        XCTAssertEqual(models[2].index, 3)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that swapping two models backward in the middle of the set works.
    func testMoveModelSwapBackwards() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(3, to: 2)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 1)
        XCTAssertEqual(models[2].index, 3)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that we can swap two models forward.
    func testMoveModelSwapTwoForwards() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(1, to: 0)

        XCTAssertEqual(models[0].index, 1)
        XCTAssertEqual(models[1].index, 0)
    }

    /// Check that we can swap two models backward.
    func testMoveModelSwapTwoBackwards() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModelAt(0, to: 1)

        XCTAssertEqual(models[0].index, 1)
        XCTAssertEqual(models[1].index, 0)
    }

    /// Check that moving a model makes minimal changes to indexes.
    func testMoveMinimizesChanges() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        try! container!.viewContext.save()

        purchase.moveModelAt(1, to: 3)

        XCTAssertFalse(models[0].hasChanges)
        XCTAssertFalse(models[4].hasChanges)
    }
}
