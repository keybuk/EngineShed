//
//  DecoderTypeIsSoundSupportedEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class DecoderTypeIsSoundSupportedEditTableViewCell : UITableViewCell {

    @IBOutlet weak var isSoundSupportedSwitch: UISwitch!

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
        isSoundSupportedSwitch.isOn = decoderType?.isSoundSupported ?? false
    }

    // MARK: - Actions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        decoderType?.isSoundSupported = isSoundSupportedSwitch.isOn
    }

}
