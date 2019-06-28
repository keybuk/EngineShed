//
//  PreviewDebug.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/27/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

#if DEBUG
import SwiftUI

extension ContentSizeCategory {

    static let other: [ContentSizeCategory] = [.extraSmall, .extraLarge, .extraExtraExtraLarge]

}

extension ColorScheme : CaseIterable {

    public static var allCases: [ColorScheme] = [.light, .dark]

}

#endif
