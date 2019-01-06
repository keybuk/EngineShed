//
//  ModelCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/12/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelCell : UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var modelClassLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    var withModelClass: Bool = true
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
        modelClassLabel.text = withModelClass ? model?.modelClass : nil
        modelImageView.image = model?.image
        numberLabel.text = model?.number
        nameLabel.text = model?.name
    }

}
