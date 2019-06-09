//
//  ModelFeaturesTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelFeaturesTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var featuresLabel: UILabel!

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
        featuresLabel.text = model?.features!.compactMap({ ($0 as! Feature).title }).sorted().joined(separator: ", ")
    }

}
