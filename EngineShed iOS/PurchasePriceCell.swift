//
//  PurchasePriceCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchasePriceCell : UITableViewCell, PurchaseSettable {

    @IBOutlet weak var priceLabel: UILabel!

    var purchase: Purchase? {
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"

        priceLabel.text = purchase?.price.flatMap({ formatter.string(from: $0) })
    }

}
