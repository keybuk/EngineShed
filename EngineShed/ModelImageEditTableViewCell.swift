//
//  ModelImageEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelImageEditTableViewCell : UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!

    var model: Model? {
        didSet {
            configureView()
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

    func configureView() {
        modelImageView.image = model?.image ?? UIImage(named: "missing-image")
    }

}
