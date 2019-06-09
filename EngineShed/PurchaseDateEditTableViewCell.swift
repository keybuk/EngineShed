//
//  PurchaseDateEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 2/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class PurchaseDateEditTableViewCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!

    var purchase: Purchase? {
        didSet {
            configureView()
            observePurchase()
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
        textField.text = purchase?.dateAsString
        clearButton.isHidden = purchase?.date == nil
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
        purchase?.dateAsString = textField.text

        // Set the field value to the re-formatted result of the date.
        textField.text = purchase?.dateAsString
        clearButton.isHidden = purchase?.date == nil
    }

    // MARK: - Object management and observation

    var observers: [NSKeyValueObservation] = []

    func observePurchase() {
        observers.removeAll()
        guard let purchase = purchase else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(purchase.observe(\.date) { (_, _) in
            DispatchQueue.main.async {
                self.textField.text = purchase.dateAsString
                self.clearButton.isHidden = purchase.date == nil
            }
        })
    }

    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        purchase?.dateAsString = textField.text
        clearButton.isHidden = purchase?.date == nil
    }

    // MARK: - Actions

    @IBAction func clearButtonTapped(_ sender: Any) {
        purchase?.date = nil
        textField.text = purchase?.dateAsString
        clearButton.isHidden = purchase?.date == nil
    }

}
