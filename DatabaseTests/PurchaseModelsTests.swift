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

        let existingModel = Model(context: container!.viewContext)
        existingModel.index = 0
        purchase.addToModels(existingModel)

        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 1)
    }

    /// Check that if there's a gap in indexes, things still work out.
    func testAddModelWithGap() {
        let purchase = Purchase(context: container!.viewContext)

        var existingModel = Model(context: container!.viewContext)
        existingModel.index = 0
        purchase.addToModels(existingModel)

        existingModel = Model(context: container!.viewContext)
        existingModel.index = 2
        purchase.addToModels(existingModel)

        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 3)
    }

    /// Check that if there's a duplication in indexes, things still work out.
    func testAddModelWithDuplicate() {
        let purchase = Purchase(context: container!.viewContext)

        var existingModel = Model(context: container!.viewContext)
        existingModel.index = 0
        purchase.addToModels(existingModel)

        existingModel = Model(context: container!.viewContext)
        existingModel.index = 1
        purchase.addToModels(existingModel)

        existingModel = Model(context: container!.viewContext)
        existingModel.index = 1
        purchase.addToModels(existingModel)

        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 2)
    }

    // MARK: removeModel

    /// Check that we can remove the only model from a purchase.
    func testRemoveModel() {
        let purchase = Purchase(context: container!.viewContext)

        let model = Model(context: container!.viewContext)
        model.index = 0
        purchase.addToModels(model)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
    }

    /// Check that we can remove a second model from a purchase.
    func testRemoveSecondModel() {
        let purchase = Purchase(context: container!.viewContext)

        let existingModel = Model(context: container!.viewContext)
        existingModel.index = 0
        purchase.addToModels(existingModel)

        let model = Model(context: container!.viewContext)
        model.index = 1
        purchase.addToModels(model)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel) ?? false)

        XCTAssertEqual(existingModel.index, 0)
    }

    /// Check that we can remove the first of two models from a purchase, and the second is reindexed.
    func testRemoveFirstModelOfTwo() {
        let purchase = Purchase(context: container!.viewContext)

        let model = Model(context: container!.viewContext)
        model.index = 0
        purchase.addToModels(model)

        let existingModel = Model(context: container!.viewContext)
        existingModel.index = 1
        purchase.addToModels(existingModel)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel) ?? false)

        XCTAssertEqual(existingModel.index, 0)
    }

    /// Check that we can remove the first of three models from a purchase, and the second and third are reindexed.
    func testRemoveFirstModelOfThree() {
        let purchase = Purchase(context: container!.viewContext)

        let model = Model(context: container!.viewContext)
        model.index = 0
        purchase.addToModels(model)

        let existingModel1 = Model(context: container!.viewContext)
        existingModel1.index = 1
        purchase.addToModels(existingModel1)

        let existingModel2 = Model(context: container!.viewContext)
        existingModel2.index = 2
        purchase.addToModels(existingModel2)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel1) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel2) ?? false)

        XCTAssertEqual(existingModel1.index, 0)
        XCTAssertEqual(existingModel2.index, 1)
    }

    /// Check that gaps before a model index aren't affected up by remove.
    func testRemoveModelAfterGap() {
        let purchase = Purchase(context: container!.viewContext)

        let existingModel1 = Model(context: container!.viewContext)
        existingModel1.index = 0
        purchase.addToModels(existingModel1)

        let existingModel2 = Model(context: container!.viewContext)
        existingModel2.index = 2
        purchase.addToModels(existingModel2)

        let model = Model(context: container!.viewContext)
        model.index = 3
        purchase.addToModels(model)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel1) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel2) ?? false)

        XCTAssertEqual(existingModel1.index, 0)
        XCTAssertEqual(existingModel2.index, 2)
    }

    /// Check that gaps after a model index are cleaned up by remove.
    func testRemoveModelBeforeGap() {
        let purchase = Purchase(context: container!.viewContext)

        let model = Model(context: container!.viewContext)
        model.index = 0
        purchase.addToModels(model)

        let existingModel1 = Model(context: container!.viewContext)
        existingModel1.index = 1
        purchase.addToModels(existingModel1)

        let existingModel2 = Model(context: container!.viewContext)
        existingModel2.index = 3
        purchase.addToModels(existingModel2)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel1) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel2) ?? false)

        XCTAssertEqual(existingModel1.index, 0)
        XCTAssertEqual(existingModel2.index, 1)
    }

    /// Check that duplicates before a model index aren't affected up by remove.
    func testRemoveModelAfterDuplicate() {
        let purchase = Purchase(context: container!.viewContext)

        let existingModel1 = Model(context: container!.viewContext)
        existingModel1.index = 0
        purchase.addToModels(existingModel1)

        let existingModel2 = Model(context: container!.viewContext)
        existingModel2.index = 0
        purchase.addToModels(existingModel2)

        let model = Model(context: container!.viewContext)
        model.index = 1
        purchase.addToModels(model)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel1) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel2) ?? false)

        XCTAssertEqual(existingModel1.index, 0)
        XCTAssertEqual(existingModel2.index, 0)
    }

    /// Check that duplicates after a model index are cleaned up by remove.
    func testRemoveModelBeforeDuplicate() {
        let purchase = Purchase(context: container!.viewContext)

        let model = Model(context: container!.viewContext)
        model.index = 0
        purchase.addToModels(model)

        let existingModel1 = Model(context: container!.viewContext)
        existingModel1.index = 1
        purchase.addToModels(existingModel1)

        let existingModel2 = Model(context: container!.viewContext)
        existingModel2.index = 1
        purchase.addToModels(existingModel2)


        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel1) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel2) ?? false)

        // Non-deterministic which way the cleanup works.
        if existingModel1.index == 0 {
            XCTAssertEqual(existingModel1.index, 0)
            XCTAssertEqual(existingModel2.index, 1)
        } else {
            XCTAssertEqual(existingModel2.index, 0)
            XCTAssertEqual(existingModel1.index, 1)
        }
    }

    /// Check that duplicates at a model index are cleaned up by remove.
    func testRemoveModelFromDuplicate() {
        let purchase = Purchase(context: container!.viewContext)

        let model = Model(context: container!.viewContext)
        model.index = 0
        purchase.addToModels(model)

        let existingModel1 = Model(context: container!.viewContext)
        existingModel1.index = 0
        purchase.addToModels(existingModel1)

        let existingModel2 = Model(context: container!.viewContext)
        existingModel2.index = 1
        purchase.addToModels(existingModel2)

        purchase.removeModel(model)

        XCTAssertTrue(model.isDeleted)
        XCTAssertNil(model.purchase)
        XCTAssertFalse(purchase.models?.contains(model) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel1) ?? false)
        XCTAssertTrue(purchase.models?.contains(existingModel2) ?? false)

        XCTAssertEqual(existingModel1.index, 0)
        XCTAssertEqual(existingModel2.index, 1)
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

        purchase.moveModel(models[4], before: models[2])

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

        purchase.moveModel(models[1], before: models[4])

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

        purchase.moveModel(models[4], before: models[4])

        for (index, model) in models.enumerated() {
            XCTAssertEqual(model.index, Int16(clamping: index))
        }
    }

    /// Check that a gap before the move isn't cleaned up.
    func testMoveModelGapBefore() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 2, 3, 4, 5, 6] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModel(models[4], before: models[2])

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 2)
        XCTAssertEqual(models[2].index, 4)
        XCTAssertEqual(models[3].index, 5)
        XCTAssertEqual(models[4].index, 3)
        XCTAssertEqual(models[5].index, 6)
    }

    /// Check that a gap after the move isn't cleaned up.
    func testMoveModelGapAfter() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 1, 2, 3, 4, 6] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModel(models[1], before: models[4])

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 3)
        XCTAssertEqual(models[2].index, 1)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 6)
    }

    /// Check that a duplicate within the move segment is cleaned up, and following models reindexed because they have to be.
    func testMoveModelDuplicateWithin() {
        let purchase = Purchase(context: container!.viewContext)

        var models: [Model] = []
        for index in [0, 1, 2, 2, 3, 4] {
            let model = Model(context: container!.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
        }

        purchase.moveModel(models[1], before: models[4])

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 3)
        // Non-deterministic which way the cleanup works.
        if models[2].index == 1 {
            XCTAssertEqual(models[2].index, 1)
            XCTAssertEqual(models[3].index, 2)
        } else {
            XCTAssertEqual(models[3].index, 1)
            XCTAssertEqual(models[2].index, 2)
        }
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }
}
