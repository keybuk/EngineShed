//
//  Purchase+Models.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Purchase {
    /// Add a new `Model` to the purchase.
    ///
    /// The new `Model` is inserted into the same `managedObjectContext` as this purchase, added to the `models`
    /// set, and the `index` set to the next value in sequence.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Returns: `Model` now present in `models`.
    public func addModel() -> Model {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot add a model to a purchase without a managed object context")
        }

        let model = Model(context: managedObjectContext)
        model.index = maxModelIndex + 1
        maxModelIndex = model.index
        addToModels(model)

        return model
    }

    /// Remove a `Model` from the purchase.
    ///
    /// `model` is removed from the `models` set, deleted from its `managedObjectContext` and all `index` of each
    /// following model in `models` adjusted.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameter model: `Model` to be removed.
    public func removeModel(_ model: Model) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot remove a model from a purchase without a managed object context")
        }
        guard let models = models as? Set<Model> else { return }

        removeFromModels(model)

        for other in models {
            if other.index > model.index {
                other.index -= 1
            }
        }

        maxModelIndex -= 1
        managedObjectContext.delete(model)
    }

    /// Move a `Model` within the purchase from one position to another.
    ///
    /// After calling this method, the model at the zero-indexes `origin` position with the set of `models`
    /// will have the new index `destination` with intermediate indexes adjusted.
    ///
    /// Note that when moving a model to a lower position, after calling this method, the model will be placed **before**
    /// the model currently at the `destination` indxes; while when moving a model to a higher position, the model
    /// will be placed **after** the model currently at the `destination`.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameters:
    ///   - origin: The position of the model that you want to move.
    ///   - destination: The model's new position.
    public func moveModelAt(_ origin: Int, to destination: Int) {
        guard let _ = managedObjectContext else {
            preconditionFailure("Cannot move a model within a purchase without a managed object context")
        }

        guard origin != destination else { return }
        guard let models = models as? Set<Model> else { return }

        for model in models {
            if (model.index == origin) {
                model.index = Int16(clamping: destination)
            } else if (destination > origin && model.index > origin && model.index <= destination) {
                model.index -= 1
            } else if (destination < origin && model.index >= destination && model.index < origin) {
                model.index += 1
            }
        }
    }
}
