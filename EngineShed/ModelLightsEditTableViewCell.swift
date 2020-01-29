//
//  ModelLightsEditTableViewCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelLightsEditTableViewCell : UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var placeholderTopConstraint: NSLayoutConstraint!

    var model: Model? {
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

        // Configure the view for the selected state
    }

    func configureView() {
        textView.text = model?.lights!.compactMap({ ($0 as! Light).title }).sorted().joined(separator: ", ")
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textView.becomeFirstResponder()
    }

    // MARK: - UITextViewDelegate

    /// Pending completion for user-entered text.
    ///
    /// We calculate the pending completion in response to user-input (should change) rather than
    /// any computed change (did change), but only apply it after the notification of change has
    /// been sent.
    var pendingCompletion: String? = nil

    enum InsertionState {

        case atSeparator
        case atDocumentEnd
        case withinText

    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        pendingCompletion = nil

        let textInput: UITextInput = textView
        let insertedText: String = text

        // The range of text that we replace is firstly the current suggestion (marked text range),
        // then the current selection, and finally the insertion point (which is a zero-length
        // selected text range).
        let insertionRange: UITextRange
        if let markedTextRange = textInput.markedTextRange {
            insertionRange = markedTextRange
        } else if let selectedTextRange = textInput.selectedTextRange {
            insertionRange = selectedTextRange
        } else {
            assertionFailure("Expected marked text or cursor when changing text")
            return true
        }

        // Look at the text after the insertion range to determine which meaningful position we're
        // doing the insertion at.
        let insertionState: InsertionState
        if let textAfterCursorEnd = textInput.position(from: insertionRange.end, offset: 1),
            let textAfterCursorRange = textInput.textRange(from: insertionRange.end, to: textAfterCursorEnd),
            let textAfterCursor = textInput.text(in: textAfterCursorRange),
            textAfterCursor == ","
        {
            insertionState = .atSeparator
        } else if insertionRange.end == textInput.endOfDocument {
            insertionState = .atDocumentEnd
        } else {
            insertionState = .withinText
        }

        // When return or tab keys are pressed, or the separator inserted, accept the current
        // suggestion or selection.
        if insertedText == "\n" || insertedText == "\t" || insertedText == "," {
            textInput.unmarkText()

            // If the cursor is already at a separator, move the insertion point past it to the
            // next entity position, otherwise move the insertion point to the end of the range and
            // insert a new separator afterwards.
            if insertionState == .atSeparator {
                let positionAfterSeparator = textInput.position(from: insertionRange.end, offset: 1)!
                textInput.selectedTextRange = textInput.textRange(from: positionAfterSeparator, to: positionAfterSeparator)
            } else {
                textInput.selectedTextRange = textInput.textRange(from: insertionRange.end, to: insertionRange.end)
                textInput.replace(textInput.selectedTextRange!, withText: ",")
            }

            return false
        }

        // Offer suggestions for completion when new text is inserted at either the end of the
        // document, or immediately before an existing separator. Text after the insertion range
        // can be safely unconsidered.
        if !insertedText.isEmpty && insertionState != .withinText,
            let textRange = textInput.textRange(from: textInput.beginningOfDocument, to: insertionRange.start),
            var text = textInput.text(in: textRange)
        {
            // Look backwards through the text for a separator, and only consider the
            // current entity for suggestion.
            if let separatorIndex = text.lastIndex(of: ",") {
                let startIndex = text.index(after: separatorIndex)
                text = String(text[startIndex...])
            }

            // If there is a suggestion at this insertion point, we'll set the marked text
            // after the text field has finished processing the change (avoiding conflict with
            // any of its own built-in operations, and assuming it places the insertion point at
            // the right place).
            text += insertedText
            if let suggestion = model?.suggestionsForLights(startingWith: text).first {
                pendingCompletion = String(suggestion.dropFirst(text.count))
            }
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let titles = textView.text.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces) }).filter({ !$0.isEmpty })
        model?.updateLights(from: titles)
        placeholderLabel.isHidden = !textView.text.isEmpty

        DispatchQueue.main.async {
            if let completion = self.pendingCompletion {
                self.textView.setMarkedText(completion, selectedRange: NSMakeRange(0, 0))
                self.pendingCompletion = nil
            }
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.unmarkText()

        // Strictly speaking this isn't necessary, but make sure the value is set at the end of
        // editing just in case something changes it during resigning of the responder, before we
        // process the notification.
        let titles = textView.text.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces) }).filter({ !$0.isEmpty })
        model?.updateLights(from: titles)
    }

}
