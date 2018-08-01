//
//  TrainMemberCollectionViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/23/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class TrainMemberCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var trainMember: TrainMember? {
        didSet {
            configureCell()
        }
    }

    func configureCell() {
        guard let trainMember = trainMember else { return }

        modelImageView.image = trainMember.image
        titleLabel.text = trainMember.title
    }

}
