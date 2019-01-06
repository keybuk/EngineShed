//
//  PurchaseDateCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchaseDateCell : UITableViewCell, PurchaseSettable {

    @IBOutlet weak var dateLabel: UILabel!

    var purchase: Purchase? {
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
        let date = purchase?.date.flatMap { dateComponents -> Date? in
            let calendar = dateComponents.calendar ?? Calendar.current
            return calendar.date(from: dateComponents as DateComponents)
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        dateLabel.text = date.flatMap({ formatter.string(from: $0) })
    }

}
