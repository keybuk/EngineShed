//
//  PurchaseRow.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

import Database

struct PurchaseRow : View {

    var purchase: Purchase

    var body: some View {
        return HStack {
            RowImage(image: Image(uiImage: (purchase.models!.anyObject() as! Model).image!))

            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(purchase.manufacturer!)
                        .font(.headline)
                    Text(" ")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    Text(purchase.catalogNumber!)
                        .font(.headline)
                        .foregroundColor(Color.primary)
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
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            List {
                ForEach(previewData.purchases, id: \.objectID) { purchase in
                    PurchaseRow(purchase: purchase)
                }

                ForEach(ContentSizeCategory.other, id: \.self) { item in
                    PurchaseRow(purchase: previewData.purchases.first!)
                        .environment(\.sizeCategory, item)
                }
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
