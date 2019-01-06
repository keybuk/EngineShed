//
//  ModelLastRunCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelLastRunCell : UITableViewCell, ModelSettable {

    @IBOutlet weak var lastRunLabel: UILabel!

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
        let date = model?.lastRun.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        lastRunLabel.text = date.flatMap({ formatter.string(from: $0) })
    }

}
