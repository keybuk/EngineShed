//
//  Model+Era.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

public struct ModelEra : Codable, Equatable, Hashable {

    var era: Int
    var title: String
    var startYear: Int
    var endYear: Int?
    
}

extension ModelEra : CustomStringConvertible {

    public var description: String {
        let description = "\(era): \(title) (\(startYear)—"
        if let endYear = endYear {
            return description + "\(endYear))"
        } else {
            return description + ")"
        }
    }

}

extension ModelEra : CaseIterable {

    public static let pioneering =                 ModelEra(era: 1, title: "Pioneering", startYear: 1804, endYear: 1875)
    public static let preGrouping =                ModelEra(era: 2, title: "Pre-grouping", startYear: 1875, endYear: 1922)
    public static let theBigFour =                 ModelEra(era: 3, title: "The Big Four - LMS, GNER, LNER & SR", startYear: 1923, endYear: 1947)
    public static let brSteamEarlyCrest =          ModelEra(era: 4, title: "BR steam. Early Crest", startYear: 1948, endYear: 1956)
    public static let brSteamLateCrest =           ModelEra(era: 5, title: "BR steam. Late Crest", startYear: 1957, endYear: 1966)
    public static let brCorporateBluePreTOPS =     ModelEra(era: 6, title: "BR Corporate Blue Pre-TOPS", startYear: 1967, endYear: 1971)
    public static let brCorporateBluePostTOPS =    ModelEra(era: 7, title: "BR Corporate Blue. Post-TOPS", startYear: 1972, endYear: 1982)
    public static let brSectorisation =            ModelEra(era: 8, title: "BR Sectorisation", startYear: 1983, endYear: 1994)
    public static let initialPrivatisation =       ModelEra(era: 9, title: "Initial Privatisation", startYear: 1995, endYear: 2004)
    public static let rebuildingOfTheRailways =    ModelEra(era: 10, title: "Rebuilding of the Railways", startYear: 2005, endYear: 2015)
    public static let currentEra =                 ModelEra(era: 11, title: "Current Era", startYear: 2016, endYear: nil)

    public static var allCases: [ModelEra] = [
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
        .currentEra
    ]

    init?(era: Int) {
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

extension ModelEra : RawRepresentable {

    public var rawValue: Int16 {
        return Int16(era)
    }

    public init?(rawValue: Int16) {
        self.init(era: Int(rawValue))
    }

}

extension Model {

    public var era: ModelEra? {
        get { return ModelEra(rawValue: eraRawValue) }
        set { eraRawValue = newValue?.rawValue ?? 0 }
    }

}
