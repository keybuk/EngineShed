//
//  DecoderTypeHasRailComEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class DecoderTypeHasRailComEditTableViewCell : UITableViewCell {

    @IBOutlet weak var hasRailComSwitch: UISwitch!

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
        hasRailComSwitch.isOn = decoderType?.hasRailCom ?? false
    }

    // MARK: - Actions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        decoderType?.hasRailCom = hasRailComSwitch.isOn
    }

}
