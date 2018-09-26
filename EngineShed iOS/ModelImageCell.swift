//
//  ModelImageCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelImageCell : UITableViewCell, ModelSettable {

    var model: Model? {
        didSet {
            configureCell()
        }
    }

    @IBOutlet weak var modelImageView: UIImageView!

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

        modelImageView?.image = model.image
    }

}
