//
//  TrainMemberIsFlippedEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class TrainMemberIsFlippedEditTableViewCell : UITableViewCell {

    @IBOutlet weak var isFlippedSwitch: UISwitch!

    var trainMember: TrainMember? {
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
        isFlippedSwitch.isOn = trainMember?.isFlipped ?? false
    }

    // MARK: - Actions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        trainMember?.isFlipped = isFlippedSwitch.isOn
    }

}
