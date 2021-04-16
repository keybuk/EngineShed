//
//  ModelWheelArrangementEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 4/16/21.
//  Copyright © 2021 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelWheelArrangementEditTableViewCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    var model: Model? {
        didSet {
            configureView()
            observeModel()
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
        textField.text = model?.wheelArrangement
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

    /// Pending completion for user-entered text.
    ///
    /// We calculate the pending completion in response to user-input (should change) rather than
    /// any computed change (did change), but only apply it after the notification of change has
    /// been sent.
    var pendingCompletion: String? = nil

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // When there is marked text, the selection (and thus `range` above) is ignored, and the
        // marked text is replaced instead.
        let text: String
        if let markedTextRange = textField.markedTextRange {
            let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: markedTextRange.start)
            let prefix = prefixRange.flatMap { textField.text(in: $0) }

            let suffixRange = textField.textRange(from: markedTextRange.end, to: textField.endOfDocument)
            let suffix = suffixRange.flatMap { textField.text(in: $0) }

            text = [ prefix, string, suffix ].compactMap({ $0 }).joined()
        } else if let textFieldText = textField.text,
            let rangeInText = Range(range, in: textFieldText)
        {
            text = textFieldText.replacingCharacters(in: rangeInText, with: string)
        } else {
            assertionFailure("Unable to construct final text")
            return true
        }

        if !string.isEmpty,
            let suggestion = model?.suggestionsForWheelArrangement(startingWith: text).first
        {
            pendingCompletion = String(suggestion.dropFirst(text.count))
        } else {
            pendingCompletion = nil
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.unmarkText()

        // Strictly speaking this isn't necessary, but make sure the value is set at the end of
        // editing just in case something changes it during resigning of the responder, before we
        // process the notification.
        model?.wheelArrangement = textField.text
    }

    // MARK: - Object management and observation

    var observers: [NSKeyValueObservation] = []

    func observeModel() {
        observers.removeAll()
        guard let model = model else { return }

        // NOTE: Swift KVO is rumored buggy across threads, so watch out for that and
        // temporarily replace with Cocoa KVO if necessary.
        observers.append(model.observe(\.wheelArrangement) { (_, _) in
            DispatchQueue.main.async {
                self.textField.text = model.wheelArrangement
            }
        })
    }

    // MARK: - Notifications

    @objc
    func textDidChange(_ notification: Notification) {
        model?.wheelArrangement = textField.text

        DispatchQueue.main.async {
            if let completion = self.pendingCompletion {
                self.textField.setMarkedText(completion, selectedRange: NSMakeRange(0, 0))
                self.pendingCompletion = nil
            }
        }
    }

}
