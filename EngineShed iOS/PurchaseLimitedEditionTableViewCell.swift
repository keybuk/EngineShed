//
//  PurchaseLimitedEditionTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchaseLimitedEditionTableViewCell : UITableViewCell, PurchaseSettable {

    @IBOutlet weak var limitedEditionLabel: UILabel!
    @IBOutlet weak var limitedEditionNumberLabel: UILabel!
    @IBOutlet weak var limitedEditionCountLabel: UILabel!

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
        limitedEditionLabel.text = purchase?.limitedEdition
        limitedEditionNumberLabel.text = (purchase?.limitedEditionNumber).flatMap({ "\($0)" })
        limitedEditionCountLabel.text = (purchase?.limitedEditionCount).flatMap({ "\($0)" })
    }

}
