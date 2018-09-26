//
//  Purchase+Index.swift
//  EngineShed
//
//  Created by Scott James Remnant on 9/25/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {

    /// Update the index fields of models.
    func updateModelIndexes() {
        guard let models = models else { return }

        for (index, model) in models.enumerated() {
            let index = Int16(clamping: index)
            let model = model as! Model
            if model.index != index { model.index = index }
        }
    }

}
