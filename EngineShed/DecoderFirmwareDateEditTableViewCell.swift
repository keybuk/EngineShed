//
//  DecoderFirmwareDateEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class DecoderFirmwareDateEditTableViewCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!

    var decoder: Decoder? {
        didSet {
            configureView()
            observeDecoder()
        }
    }
    
    var pickerVisible = false {
        didSet {
            textField.textColor = pickerVisible ? textField.tintColor : defaultTextColor
        }
    }

    var defaultTextColor: UIColor!

    override func awakeFromNib() {
        super.awakeFromNib()

        defaultTextColor = textField.textColor

        // UITextFieldDelegate lacks a textFieldDidChange, but has a Notification we can use instead
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: textField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureView() {
        textField.text = decoder?.firmwareDateAsString
        clearButton.isHidden = decoder?.firmwareDate == nil
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField.becomeFirstResponder()
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Strictly speaking this isn't necessary, but make sure the value is set at the end of
        // editing just in case something changes it during resigning of the responder, before we
        // process the notification.
        // FIXME: date
        decoder?.firmwareDateAsString = textField.text

        // Set the field value to the re-formatted result of the date.
        textField.text = decoder?.firmwareDateAsString
        clearButton.isHidden = decoder?.firmwareDate == nil
    }

    // MARK: - Object management and observation

    var observers: [NSKeyValueObservation] = []

    func observeDecoder() {
        observers.removeAll()
        guard let decoder = decoder else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(decoder.observe(\.firmwareDate) { (_, _) in
            DispatchQueue.main.async {
                self.textField.text = decoder.firmwareDateAsString
                self.clearButton.isHidden = decoder.firmwareDate == nil
            }
        })
    }

    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        decoder?.firmwareDateAsString = textField.text
        clearButton.isHidden = decoder?.firmwareDate == nil
    }

    // MARK: - Actions

    @IBAction func clearButtonTapped(_ sender: Any) {
        decoder?.firmwareDate = nil
        textField.text = decoder?.firmwareDateAsString
        clearButton.isHidden = decoder?.firmwareDate == nil
    }

}
