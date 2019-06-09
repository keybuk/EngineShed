//
//  PurchaseDatePickerTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/3/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class PurchaseDatePickerTableViewCell : UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    var purchase: Purchase? {
        didSet {
            configureView()
        }
    }

    var resignFirstResponderBlock: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureView() {
        // When the picker is shown, default the date in the purchase as today to match the
        // picker.
        if purchase?.dateAsDate == nil { purchase?.dateAsDate = Date() }
        datePicker.date = purchase?.dateAsDate ?? Date()
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        resignFirstResponderBlock?()
        return true
    }

    // MARK: - Actions

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        purchase?.dateAsDate = datePicker.date
    }

}
