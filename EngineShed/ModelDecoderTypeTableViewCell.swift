//
//  ModelDecoderTypeTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelDecoderTypeTableViewCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var decoderTypeLabel: UILabel!

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
        decoderTypeLabel.text = [
            model?.decoder?.type?.manufacturer,
            model?.decoder?.type?.productCode,
            model?.decoder?.type?.productFamily,
            model?.decoder?.type?.socket.flatMap({ "(\($0))" })
        ].compactMap({ $0 }).joined(separator: " ")
    }

}
