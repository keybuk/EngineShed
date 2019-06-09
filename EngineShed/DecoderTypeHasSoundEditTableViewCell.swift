//
//  DecoderTypeHasSoundEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class DecoderTypeHasSoundEditTableViewCell : UITableViewCell {

    @IBOutlet weak var hasSoundSwitch: UISwitch!

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
        hasSoundSwitch.isOn = decoderType?.hasSound ?? false
    }

    // MARK: - Actions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        decoderType?.hasSound = hasSoundSwitch.isOn
    }

}
