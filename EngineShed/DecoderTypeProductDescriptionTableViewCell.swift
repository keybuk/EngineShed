//
//  DecoderTypeProductDescriptionTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class DecoderTypeProductDescriptionTableViewCell : UITableViewCell {

    @IBOutlet weak var productDescriptionLabel: UILabel!

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
        productDescriptionLabel.text = decoderType?.productDescription
    }

}
