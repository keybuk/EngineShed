//
//  TrainNotesEditTableViewCell.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 1/1/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class TrainNotesEditTableViewCell : UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var placeholderTopConstraint: NSLayoutConstraint!

    var train: Train? {
        didSet {
            configureView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Remove the leading padding from the text view to match the other text fields.
        textView.textContainer.lineFragmentPadding = 0

        // Align the placeholder with the first line, and set the initial hidden state.
        placeholderTopConstraint.constant = textView.textContainerInset.top
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            textView.becomeFirstResponder()
        }
    }

    func configureView() {
        textView.text = train?.notes
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        train?.notes = textView.text
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Strictly speaking this isn't necessary, but make sure the value is set at the end of
        // editing just in case something changes it during resigning of the responder, before we
        // process the notification.
        train?.notes = textView.text
    }

}
