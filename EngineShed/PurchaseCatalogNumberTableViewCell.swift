//
//  PurchaseCatalogNumberTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class PurchaseCatalogNumberTableViewCell : UITableViewCell, PurchaseSettable {

    @IBOutlet weak var catalogNumberLabel: UILabel!

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
        catalogNumberLabel.text = purchase?.catalogNumber
    }

}
