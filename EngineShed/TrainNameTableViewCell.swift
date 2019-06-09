//
//  TrainNameTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class TrainNameTableViewCell : UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    var train: Train? {
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
        nameLabel.text = train?.name
    }

}
