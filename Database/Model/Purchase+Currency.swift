//
//  Purchase+Currency.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/2/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Purchase {
    /// Formatter for `price`.
    public var priceFormatter: NumberFormatter {
        let locale = Locale(identifier: priceCurrency ?? "")

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.generatesDecimalNumbers = true
        return formatter
    }

    /// `price` formatted as string using `priceFormatter`.
    public var priceAsString: String? {
        get { price.flatMap { priceFormatter.string(from: $0) } }
        set {
            price = newValue.flatMap {
                priceFormatter.number(from: $0) as? NSDecimalNumber
            }
        }
    }

    /// Formatter for `valuation`.
    public var valuationFormatter: NumberFormatter {
        let locale = Locale(identifier: valuationCurrency ?? "")

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.generatesDecimalNumbers = true
        return formatter
    }

    /// `valuation` formatted as string using `valuationFormatter`.
    public var valuationAsString: String? {
        get { valuation.flatMap { valuationFormatter.string(from: $0) } }
        set {
            valuation = newValue.flatMap {
                valuationFormatter.number(from: $0) as? NSDecimalNumber
            }
        }
    }
}
