//
//  TrainEditMemberCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/1/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class TrainEditMemberCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    var trainMember: TrainMember? {
        didSet {
            configureView()
        }
    }

    func configureView() {
        guard let trainMember = trainMember else { return }

        textField.text = trainMember.title
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // UITextFieldDelegate lacks a textFieldDidChange, but has a Notification we can use instead
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: textField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            textField.becomeFirstResponder()
        }
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
        trainMember?.title = textField.text
    }

    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        trainMember?.title = textField.text
    }

}
