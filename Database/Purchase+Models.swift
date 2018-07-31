//
//  Purchase+Models.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/26/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

extension Model : IndexSortable {}

extension Purchase {

    public func appendModel(_ model: Model) {
        let models = (self.models as! Set<Model>).sorted()
        model.index = models.indexForAppending()
        addToModels(model)
    }

    public func insertModel(_ model: Model, at index: Int) {
        let models = (self.models as! Set<Model>).sorted()
        model.index = models.indexForInserting(at: index)
        addToModels(model)
    }

}
