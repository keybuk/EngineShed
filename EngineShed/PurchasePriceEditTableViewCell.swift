//
//  PurchasePriceEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class PurchasePriceEditTableViewCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    var purchase: Purchase? {
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
        textField.text = purchase?.priceAsString
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Place the currency symbol at the start of the text field when editing an empty value.
        if purchase?.price == nil {
            textField.text = purchase?.priceFormatter.currencySymbol
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else { preconditionFailure("Replacing characters in range of nil text") }
        guard let range = Range(range, in: text) else { preconditionFailure("Range doesn't map to text") }
        text.replaceSubrange(range, with: string)

        // Allow a valid currency number, and just the currency symbol; but don't allow that to be
        // deleted.
        let asNumber = purchase?.priceFormatter.number(from: text)
        return asNumber != nil || text == purchase?.priceFormatter.currencySymbol
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Strictly speaking this isn't necessary, but make sure the value is set at the end of
        // editing just in case something changes it during resigning of the responder, before we
        // process the notification.
        purchase?.priceAsString = textField.text

        // Set the field value to the re-formatted result of the number. This both corrects the
        // number of decimal places, as well as removes the currency symbol when left blank.
        textField.text = purchase?.priceAsString
    }

    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        purchase?.priceAsString = textField.text
    }

}
