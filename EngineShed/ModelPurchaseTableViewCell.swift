//
//  ModelPurchaseTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelPurchaseTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var purchaseLabel: UILabel!
    @IBOutlet weak var purchaseDescriptionLabel: UILabel!

    var model: Model? {
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
        purchaseLabel.text = [ model?.purchase?.manufacturer, model?.purchase?.catalogNumber ].compactMap({ $0 }).joined(separator: " ")
        purchaseDescriptionLabel.text = model?.purchase?.catalogDescription
    }

}
