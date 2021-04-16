//
//  ModelWheelArrangementTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 4/16/21.
//  Copyright © 2021 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelWheelArrangementTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var wheelArrangementLabel: UILabel!

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
        wheelArrangementLabel.text = model?.wheelArrangement
    }

}
