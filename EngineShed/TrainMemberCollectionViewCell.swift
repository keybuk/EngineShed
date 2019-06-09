//
//  TrainMemberCollectionViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/23/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

class TrainMemberCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var trainMember: TrainMember? {
        didSet {
            configureCell()
        }
    }

    func configureCell() {
        if let _ = trainMember?.model {
            modelImageView.image = trainMember?.image ?? UIImage(named: "missing-image")
        } else {
            modelImageView.image = UIImage(named: "missing-model")
        }

        titleLabel.text = trainMember?.title
    }

}
