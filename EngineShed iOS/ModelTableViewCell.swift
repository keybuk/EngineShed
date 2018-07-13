//
//  ModelTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/12/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelTableViewCell: UITableViewCell {

    var withModelClass: Bool = true
    var model: Model? {
        didSet {
            configureCell()
        }
    }

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var modelClassLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell() {
        guard let model = model else { return }

        modelClassLabel.text = withModelClass ? model.modelClass : nil
        modelImageView.image = model.image
        numberLabel.text = model.number
        nameLabel.text = model.name
    }

}
