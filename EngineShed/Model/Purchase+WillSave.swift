//
//  Purchase+WillSave.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {

    public override func willSave() {
        updateCatalogNumberPrefix()
        updateDateForSort()
    }

}
