//
//  PurchaseCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchaseCell : UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var catalogNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var storeLabel: UILabel!

    var ordering: PurchaseOrdering = .catalog {
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

        if ordering == .catalog {
            catalogNumberLabel.text = purchase?.catalogNumber
        } else {
            catalogNumberLabel.text = [ purchase?.manufacturer, purchase?.catalogNumber ].compactMap({ $0 }).joined(separator: " ")
        }

        dateLabel.text = purchase?.dateAsString

        storeLabel.text = purchase?.store
    }

}
