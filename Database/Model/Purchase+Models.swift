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
    /// Update the indexes of the `models`.
    ///
    /// - Parameter changing: closure to make changes to the `models` list, invoked between sorting `models` and
    /// applying new indexes.
    func updateModelIndexes(changing: ((inout [Model]) -> Void)? = nil) {
        guard let models = models as? Set<Model> else { return }

        var sortedModels = models.sorted { $0.index < $1.index }
        changing?(&sortedModels)

        for (newIndex, model) in sortedModels.enumerated() {
            if model.index != newIndex { model.index = Int16(clamping: newIndex) }
        }
    }

    /// Add a new `Model` to the purchase.
    ///
    /// The new `Model` is inserted into the same `managedObjectContext` as this purchase, added to the `models`
    /// set, and the `index` set to the next value in sequence.
    ///
    /// - Returns: `Model` now present in `models`.
    public func addModel() -> Model {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot add a model to a purchase without a managed object context")
        }

        var model: Model!
        managedObjectContext.performAndWait {
            model = Model(context: managedObjectContext)
            updateModelIndexes {
                $0.append(model)
            }
            addToModels(model)
        }
        return model
    }

    /// Remove a `Model` from the purchase.
    ///
    /// `model` is removed from the `models` set, deleted from its `managedObjectContext` and all `index` of each
    /// other model in `models` adjusted.
    ///
    /// - Parameter model: `Model` to be removed.
    public func removeModel(_ model: Model) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot remove a model from a purchase without a managed object context")
        }

        managedObjectContext.performAndWait {
            removeFromModels(model)
            updateModelIndexes()
            managedObjectContext.delete(model)
        }
    }

    /// Move a `Model` within the purchase from one position to another.
    ///
    /// After calling this method, the model at the zero-indexes `origin` position with the set of `models`
    /// will have the new index `destination` with all indexes adjusted.
    ///
    /// Note that when moving a model to a lower position, after calling this method, the model will be placed **before**
    /// the model currently at the `destination` indxes; while when moving a model to a higher position, the model
    /// will be placed **after** the model currently at the `destination`.
    ///
    /// - Parameters:
    ///   - origin: The position of the model that you want to move.
    ///   - destination: The model's new position.
    public func moveModelAt(_ origin: Int, to destination: Int) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot move a model within a purchase without a managed object context")
        }

        guard origin != destination else { return }
        managedObjectContext.performAndWait {
            updateModelIndexes() {
                let originIndex = $0.index($0.startIndex, offsetBy: origin)
                let destinationIndex = $0.index($0.startIndex, offsetBy: destination)
                $0.insert($0.remove(at: originIndex), at: destinationIndex)
            }
        }
    }
}
