//
//  TrainMemberEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/1/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class TrainMemberEditTableViewCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    var trainMember: TrainMember? {
        didSet {
            configureView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // UITextFieldDelegate lacks a textFieldDidChange, but has a Notification we can use instead
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: textField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureView() {
        textField.text = trainMember?.details
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
        trainMember?.details = textField.text
    }

    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        trainMember?.details = textField.text
    }

}
