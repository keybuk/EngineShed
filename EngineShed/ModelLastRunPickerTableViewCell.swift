//
//  ModelLastRunPickerTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelLastRunPickerTableViewCell : UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    var model: Model? {
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
        // When the picker is shown, default the date to today to match the picker.
        if model?.lastRunAsDate == nil { model?.lastRunAsDate = Date() }
        datePicker.date = model?.lastRunAsDate ?? Date()
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
        model?.lastRunAsDate = datePicker.date
    }

}
