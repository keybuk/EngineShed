//
//  PurchaseRow.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PurchaseRow : View {

    var purchase: Purchase

    var body: some View {
        return HStack {
            RowImage(image: Image(uiImage: (purchase.models!.firstObject as! Model).image!))

            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(purchase.manufacturer!)
                        .font(.headline)
                    Text(" ")
                        .font(.headline)
                        .color(Color.primary)
                    Text(purchase.catalogNumber!)
                        .font(.headline)
                        .color(Color.primary)
                }
                Text("\(purchase.dateAsDate!, formatter: purchase.dateFormatter)")
                Text(purchase.store!)
                    .font(.caption)
            }
        }
    }
}

#if DEBUG
struct PurchaseRow_Previews : PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.identified(by: \.self)) { colorScheme in
            List {
                ForEach(previewData.purchases.identified(by: \.objectID)) { purchase in
                    PurchaseRow(purchase: purchase)
                }

                ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                    PurchaseRow(purchase: previewData.purchases.first!)
                        .environment(\.sizeCategory, item)
                }
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
