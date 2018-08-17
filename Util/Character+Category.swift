//
//  Character+Category.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/22/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Character {

    public enum Category {
        // TODO: Remove once SE-0211 is implemented.
        case decimalDigit
        case letter
        case punctuation
        case symbol
        case newline
        case whitespace
        case controlCharacter
        case other
    }

    /// Returns the Unicode category of this character.
    public var category: Category {
        // TODO: Update once SE-0211 is implemented.
        let scalars = CharacterSet(unicodeScalars)
        if CharacterSet.decimalDigits.isSuperset(of: scalars) {
            return .decimalDigit
        } else if CharacterSet.letters.isSuperset(of: scalars) {
            return .letter
        } else if CharacterSet.punctuationCharacters.isSuperset(of: scalars) {
            return .punctuation
        } else if CharacterSet.symbols.isSuperset(of: scalars) {
            return .symbol
        } else if CharacterSet.controlCharacters.isSuperset(of: scalars) {
            return .controlCharacter
        } else if CharacterSet.newlines.isSuperset(of: scalars) {
            return .newline
        } else if CharacterSet.whitespaces.isSuperset(of: scalars) {
            return .whitespace
        } else {
            return .other
        }
    }

}
