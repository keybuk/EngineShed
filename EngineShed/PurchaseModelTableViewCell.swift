//
//  PurchaseModelTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchaseModelTableViewCell : UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var modelClassLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    var model: Model? {
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
        modelImageView.image = model?.image
        modelClassLabel.text = model?.modelClass
        numberLabel.text = model?.number
        nameLabel.text = model?.name
    }

}
