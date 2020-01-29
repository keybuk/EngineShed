//
//  DecoderFirmwareDateTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class DecoderFirmwareDateTableViewCell : UITableViewCell {

    @IBOutlet weak var firmwareDateLabel: UILabel!

    var decoder: Decoder? {
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
        firmwareDateLabel.text = decoder?.firmwareDateAsString
    }

}
