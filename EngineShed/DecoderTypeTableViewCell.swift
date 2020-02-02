//
//  DecoderTypeTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class DecoderTypeTableViewCell : UITableViewCell {

    @IBOutlet weak var decoderTypeImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productFamilyLabel: UILabel!
    @IBOutlet weak var socketLabel: UILabel!
    @IBOutlet weak var stockButton: UIButton!

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
        productLabel.text = [ decoderType?.manufacturer, decoderType?.productCode ].compactMap({ $0 }).joined(separator: " ")
        productFamilyLabel.text = decoderType?.productFamily
        socketLabel.text = decoderType?.socket

        if decoderType?.isStocked ?? false {
            stockButton.setTitle("\(decoderType?.remainingStockAsString ?? "")", for: .normal)
            stockButton.isHidden = false

            if decoderType?.isStockLow ?? false {
                stockButton.tintColor = UIColor(named: "stockLowColor")
            } else {
                stockButton.tintColor = UIColor(named: "stockNormalColor")
            }
        } else {
            stockButton.setTitle(nil, for: .normal)
            stockButton.isHidden = true
        }
    }

}
