//
//  ModelPurchaseCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelPurchaseCell : UITableViewCell, ModelSettable {

    var model: Model? {
        didSet {
            configureCell()
        }
    }

    @IBOutlet weak var purchaseLabel: UILabel!
    @IBOutlet weak var purchaseDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell() {
        guard let purchase = model?.purchase else { return }

        purchaseLabel.text = [ purchase.manufacturer, purchase.catalogNumber ].compactMap({ $0 }).joined(separator: " ")
        purchaseDescriptionLabel.text = purchase.catalogDescription
    }

}
