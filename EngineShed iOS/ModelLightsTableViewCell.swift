//
//  ModelLightsTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelLightsTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var lightsLabel: UILabel!

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
        lightsLabel.text = model?.lights!.compactMap({ ($0 as! Light).title }).sorted().joined(separator: ", ")
    }

}
