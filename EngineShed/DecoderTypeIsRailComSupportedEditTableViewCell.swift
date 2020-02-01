//
//  DecoderTypeIsRailComSupportedEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class DecoderTypeIsRailComSupportedEditTableViewCell : UITableViewCell {

    @IBOutlet weak var isRailComSupportedSwitch: UISwitch!

    var decoderType: DecoderType? {
        didSet {
            configureView()
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

    func configureView() {
        isRailComSupportedSwitch.isOn = decoderType?.isRailComSupported ?? false
    }

    // MARK: - Actions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        decoderType?.isRailComSupported = isRailComSupportedSwitch.isOn
    }

}
