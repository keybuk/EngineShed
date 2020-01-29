//
//  TrainMember+Image.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/18/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

extension TrainMember {

    var image: UIImage? {
        model?.image.map {
            isFlipped ? $0.withHorizontallyFlippedOrientation() : $0
        }
    }

}
