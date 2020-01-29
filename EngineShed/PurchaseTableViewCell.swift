//
//  PurchaseTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchaseTableViewCell : UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var catalogNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var storeLabel: UILabel!

    var ordering: Purchase.Ordering = .catalog {
        didSet {
            configureCell()
        }
    }

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
        modelImageView.image = (purchase?.models?.firstObject as? Model)?.image

        manufacturerLabel.text = purchase?.manufacturer
        manufacturerLabel.isHidden = ordering == .catalog
        catalogNumberLabel.text = purchase?.catalogNumber

        dateLabel.text = purchase?.dateAsString

        storeLabel.text = purchase?.store
    }

}
