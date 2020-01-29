//
//  PurchaseConditionEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchaseConditionEditTableViewCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    var purchase: Purchase? {
        didSet {
            configureView()
            observePurchase()
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

        if selected {
            textField.becomeFirstResponder()
        }
    }

    func configureView() {
        textField.text = purchase?.condition.flatMap { "\($0)" }
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
        // FIXME: enum
//        purchase?.condition = textField.text
    }

    // MARK: - Object management and observation

    var observers: [NSKeyValueObservation] = []

    func observePurchase() {
        observers.removeAll()
        guard let purchase = purchase else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(purchase.observe(\.conditionRawValue) { (_, _) in
            DispatchQueue.main.async {
                self.textField.text = purchase.condition.flatMap { "\($0)" }
            }
        })
    }


    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        // FIXME: enum
//        purchase?.condition = textField.text
    }

}
