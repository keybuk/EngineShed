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

    func addModel(_ model: Model) {
        addToModels(model)
    }

    func removeModel(_ model: Model) {
        removeFromModels(model)
    }

    func moveMember(from fromIndex: Int, to toIndex: Int) {

    }

}
