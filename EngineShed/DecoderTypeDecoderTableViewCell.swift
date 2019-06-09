//
//  DecoderTypeDecoderTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class DecoderTypeDecoderTableViewCell : UITableViewCell {

    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var soundAuthorLabel: UILabel!
    @IBOutlet weak var soundProjectLabel: UILabel!

    var decoder: Decoder? {
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
        serialNumberLabel.text = decoder?.serialNumber
        soundAuthorLabel.text = decoder?.soundAuthor
        soundAuthorLabel.isHidden = (decoder?.soundAuthor?.isEmpty ?? true)
        soundProjectLabel.text = decoder?.soundProject
        soundProjectLabel.isHidden = (decoder?.soundProject?.isEmpty ?? true)
    }

}
