//
//  TrainMemberTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class TrainMemberTableViewCell : UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var trainMember: TrainMember? {
        didSet {
            configureCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
