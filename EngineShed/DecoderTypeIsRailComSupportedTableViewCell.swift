//
//  DecoderTypeIsRailComSupportedTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class DecoderTypeIsRailComSupportedTableViewCell : UITableViewCell {

    @IBOutlet weak var isRailComSupportedLabel: UILabel!

    var decoderType: DecoderType? {
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
        isRailComSupportedLabel.text = (decoderType?.isRailComSupported ?? false) ? "Yes" : "No"
    }

}
