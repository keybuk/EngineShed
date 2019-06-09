//
//  ClassificationTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ClassificationTableViewCell : UITableViewCell {

    @IBOutlet weak var classificationImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    var classification: ModelClassification? {
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
        descriptionLabel.text = classification?.description
    }

}
