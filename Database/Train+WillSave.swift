//
//  Train+WillSave.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CoreData

extension Train {

    public override func willSave() {
        updateMemberIndexes()
    }

}
