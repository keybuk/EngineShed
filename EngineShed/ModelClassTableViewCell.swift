//
//  ModelClassTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelClassTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var classLabel: UILabel!
    
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
        classLabel.text = model?.modelClass
    }

}
