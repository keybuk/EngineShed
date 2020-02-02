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
    /// - Returns: `Model` now present in `models`.
    public func addModel() -> Model {
        var maxIndex: Int16?
        if let models = models {
            for case let model as Model in models {
                if maxIndex == nil || model.index > maxIndex! {
                    maxIndex = model.index
                }
            }
        }

        let model = Model(entity: Model.entity(), insertInto: managedObjectContext)
        if let maxIndex = maxIndex {
            model.index = maxIndex + 1
        } else {
            model.index = 0
        }

        addToModels(model)

        return model
    }

    /// Remove a `Model` from the purchase.
    ///
    /// `model` is removed from the `models` set, deleted from its `managedObjectContext` and all `index` of each
    /// other model in `models` adjusted.
    /// - Parameter model: `Model` to be removed.
    public func removeModel(_ model: Model) {
        removeFromModels(model)

        if let models = models {
            var followingModels: [Model] = []
            for case let followingModel as Model in models {
                if followingModel.index >= model.index {
                    followingModels.append(followingModel)
                }
            }

            followingModels.sort { $0.index < $1.index }
            for (offset, followingModel) in followingModels.enumerated() {
                followingModel.index = model.index + Int16(clamping: offset)
            }
        }

        managedObjectContext?.delete(model)
    }

    /// Move a `Model` within the purchase.
    /// - Parameters:
    ///   - model: `Model` to be moved.
    ///   - otherModel: `Model` that `model` is to be placed before.
    public func moveModel(_ model: Model, before otherModel: Model) {
        guard model != otherModel else { return }

        let indexes = min(model.index, otherModel.index)...max(model.index, otherModel.index)

        if let models = models {
            var reoderModels: [Model] = []
            var followingModels: [Model] = []
            for case let reoderModel as Model in models {
                guard reoderModel != model else { continue }
                if indexes.contains(reoderModel.index) {
                    reoderModels.append(reoderModel)
                } else if reoderModel.index > indexes.upperBound {
                    followingModels.append(reoderModel)
                }
            }

            reoderModels.sort { $0.index < $1.index }
            reoderModels.insert(model, at: reoderModels.firstIndex(of: otherModel)!)
            if reoderModels.count > indexes.count {
                print("FIXING: more models within move than indexes available")
                followingModels.sort { $0.index < $1.index }
                reoderModels.append(contentsOf: followingModels)
            }

            for (offset, reoderModel) in reoderModels.enumerated() {
                reoderModel.index = indexes.lowerBound + Int16(clamping: offset)
            }
        }
    }
}
