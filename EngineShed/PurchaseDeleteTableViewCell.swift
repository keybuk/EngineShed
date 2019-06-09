//
//  PurchaseDeleteTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class PurchaseDeleteTableViewCell : UITableViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        label.textColor = label.tintColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
