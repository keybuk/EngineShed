//
//  Purchase+WillSave.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CoreData

extension Purchase {

    public override func willSave() {
        updateCatalogNumberPrefix()

        if let models = models {
            for (index, model) in models.enumerated() {
                let index = Int16(clamping: index)
                let model = model as! Model
                if model.index != index { model.index = index }
            }
        }
    }

}
