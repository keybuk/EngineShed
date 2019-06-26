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
fileprivate extension ContentSizeCategory {

    static let other: [ContentSizeCategory] = [.large, .extraSmall, .extraLarge]

}

struct PurchaseRow_Previews : PreviewProvider {
    static var previews: some View {
        let p = Purchase(entity: Purchase.entity(), insertInto: nil)
        p.manufacturer = "Hornby"
        p.catalogNumber = "R3612"
        p.date = DateComponents(year: 2018, month: 8, day: 1)
        p.store = "Hattons"

        let m = Model(entity: Model.entity(), insertInto: nil)
        m.purchase = p
        m.image = UIImage(named: "R3612")
        p.addToModels(m)

        let p2 = Purchase(entity: Purchase.entity(), insertInto: nil)
        p2.manufacturer = "Locomotion Models"
        p2.catalogNumber = "R453875"
        p2.date = DateComponents(year: 2018, month: 12, day: 27)
        p2.store = "Locomotion Models"

        let m2 = Model(entity: Model.entity(), insertInto: nil)
        m2.purchase = p2
        m2.image = UIImage(named: "R3612")
        p2.addToModels(m2)

        return Group {
            PurchaseRow(purchase: p)

            PurchaseRow(purchase: p2)

            ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                PurchaseRow(purchase: p)
                    .environment(\.sizeCategory, item)
            }

            PurchaseRow(purchase: p)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 320, alignment: .leading)
        .previewLayout(.sizeThatFits)
    }
}
#endif
