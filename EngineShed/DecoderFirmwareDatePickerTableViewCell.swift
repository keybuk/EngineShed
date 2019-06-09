//
//  DecoderFirmwareDatePickerTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class DecoderFirmwareDatePickerTableViewCell : UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    var decoder: Decoder? {
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
        // When the picker is shown, default the date in the decoder as today to match the
        // picker.
        if decoder?.firmwareDateAsDate == nil { decoder?.firmwareDateAsDate = Date() }
        datePicker.date = decoder?.firmwareDateAsDate ?? Date()
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
        decoder?.firmwareDateAsDate = datePicker.date
    }

}
