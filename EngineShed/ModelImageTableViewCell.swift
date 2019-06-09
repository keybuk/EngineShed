//
//  ModelImageTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelImageTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var modelImageView: UIImageView!

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
        modelImageView?.image = model?.image ?? UIImage(named: "missing-image")
    }

}
