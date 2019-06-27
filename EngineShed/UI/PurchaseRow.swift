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
        let image = (purchase.models!.firstObject as! Model).image!

        return HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(4)
                .padding(2)
                .frame(width: 100)
                .aspectRatio(16/9, contentMode: .fit)

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
        return Group {
            ForEach(previewData.purchases.identified(by: \.objectID)) { purchase in
                PurchaseRow(purchase: purchase)
            }

            ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                PurchaseRow(purchase: previewData.purchases.first!)
                    .environment(\.sizeCategory, item)
            }

            PurchaseRow(purchase: previewData.purchases.first!)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 320, alignment: .leading)
        .previewLayout(.sizeThatFits)
    }
}
#endif
