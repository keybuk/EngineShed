//
//  Model+Era.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {
    public struct Era {
        var era: Int
        var title: String
        var startYear: Int
        var endYear: Int?
    }
}

// Only the `era` member is relevant for `Equatable` and `Hashable` conformance.
extension Model.Era: Equatable, Hashable {
    public static func == (lhs: Model.Era, rhs: Model.Era) -> Bool { lhs.era == rhs.era }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(era)
    }
}

// Extend `Model.Era` to act like an enumeration of fixed values.
extension Model.Era: CaseIterable {
    public static let pioneering =
        Model.Era(era: 1, title: "Pioneering", startYear: 1804, endYear: 1875)
    public static let preGrouping =
        Model.Era(era: 2, title: "Pre-grouping", startYear: 1875, endYear: 1922)
    public static let theBigFour =
        Model.Era(era: 3, title: "The Big Four - LMS, GNER, LNER & SR", startYear: 1923, endYear: 1947)
    public static let brSteamEarlyCrest =
        Model.Era(era: 4, title: "BR steam. Early Crest", startYear: 1948, endYear: 1956)
    public static let brSteamLateCrest =
        Model.Era(era: 5, title: "BR steam. Late Crest", startYear: 1957, endYear: 1966)
    public static let brCorporateBluePreTOPS =
        Model.Era(era: 6, title: "BR Corporate Blue Pre-TOPS", startYear: 1967, endYear: 1971)
    public static let brCorporateBluePostTOPS =
        Model.Era(era: 7, title: "BR Corporate Blue. Post-TOPS", startYear: 1972, endYear: 1982)
    public static let brSectorisation =
        Model.Era(era: 8, title: "BR Sectorisation", startYear: 1983, endYear: 1994)
    public static let initialPrivatisation =
        Model.Era(era: 9, title: "Initial Privatisation", startYear: 1995, endYear: 2004)
    public static let rebuildingOfTheRailways =
        Model.Era(era: 10, title: "Rebuilding of the Railways", startYear: 2005, endYear: 2015)
    public static let currentEra =
        Model.Era(era: 11, title: "Current Era", startYear: 2016, endYear: nil)

    public static var allCases: [Model.Era] = [
        .pioneering,
        .preGrouping,
        .theBigFour,
        .brSteamEarlyCrest,
        .brSteamLateCrest,
        .brCorporateBluePreTOPS,
        .brCorporateBluePostTOPS,
        .brSectorisation,
        .initialPrivatisation,
        .rebuildingOfTheRailways,
        .currentEra,
    ]

    /// Initialize a structure from a standard era.
    /// - Parameter era: standard era number.
    public init?(era: Int) {
        switch era {
        case 1: self = .pioneering
        case 2: self = .preGrouping
        case 3: self = .theBigFour
        case 4: self = .brSteamEarlyCrest
        case 5: self = .brSteamLateCrest
        case 6: self = .brCorporateBluePreTOPS
        case 7: self = .brCorporateBluePostTOPS
        case 8: self = .brSectorisation
        case 9: self = .initialPrivatisation
        case 10: self = .rebuildingOfTheRailways
        case 11: self = .currentEra
        default: return nil
        }
    }
}

// Extend `Model.Era` to act like an enum we can store in and fetch from a database.
extension Model.Era: RawRepresentable {
    public var rawValue: Int16 { Int16(era) }

    public init?(rawValue: Int16) {
        self.init(era: Int(rawValue))
    }
}

extension Model {
    public var era: Era? {
        get { Era(rawValue: eraRawValue) }
        set { eraRawValue = newValue?.rawValue ?? 0 }
    }
}

extension Model.Era: CustomStringConvertible, ConvertibleFromString {
    public var description: String {
        "\(era): \(title) (\(startYear)—" + (endYear.map { "\($0)" } ?? "") + ")"
    }
}
