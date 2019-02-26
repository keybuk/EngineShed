//
//  ModelCouplingsTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelCouplingsTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var couplingsLabel: UILabel!

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
        couplingsLabel.text = model?.couplings!.compactMap({ ($0 as! Coupling).title }).sorted().joined(separator: ", ")
    }

}
