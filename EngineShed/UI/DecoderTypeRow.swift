//
//  DecoderTypeRow.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct DecoderTypeRow : View {

    var decoderType: DecoderType

    var body: some View {
        return HStack {
            Image("58419")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(4)
                .padding(2)
                .frame(width: 100)
                .aspectRatio(16/9, contentMode: .fit)

            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(decoderType.manufacturer!)
                        .font(.headline)
                    Text(" ")
                        .font(.headline)
                    Text(decoderType.productCode!)
                        .font(.headline)
                        .layoutPriority(1)
                }
                Text(decoderType.productFamily!)
                Text(decoderType.socket!)
                    .font(.caption)
            }

            if decoderType.minimumStock > 0 {
                if decoderType.remainingStock < decoderType.minimumStock {
                    Text("\(decoderType.remainingStock)")
                        .font(.callout)
                        .color(Color("stockLowTextColor"))
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 4)
                        .background(Capsule().fill(Color("stockLowColor")))
                        .padding([.leading, .trailing])
                } else {
                    Text("\(decoderType.remainingStock)")
                        .font(.callout)
                        .color(Color("stockNormalTextColor"))
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 4)
                        .background(Capsule().fill(Color("stockNormalColor")))
                        .padding([.leading, .trailing])
                }
            }

        }
    }
}

#if DEBUG
fileprivate extension ContentSizeCategory {

    static let other: [ContentSizeCategory] = [.large, .extraSmall, .extraLarge]

}

struct DecoderTypeRow_Previews : PreviewProvider {
    static var previews: some View {
        let dt = DecoderType(entity: DecoderType.entity(), insertInto: nil)
        dt.manufacturer = "ESU"
        dt.productCode = "58429"
        dt.productFamily = "LokSound 5 DCC"
        dt.socket = "21MTC"
        dt.minimumStock = 5

        let dt2 = DecoderType(entity: DecoderType.entity(), insertInto: nil)
        dt2.manufacturer = "ESU"
        dt2.productCode = "58420"
        dt2.productFamily = "LokSound 5 DCC"
        dt2.socket = "8-pin NEM652"
        dt2.minimumStock = 5

        for _ in 0..<10 {
            let d = Decoder(entity: Decoder.entity(), insertInto: nil)
            d.type = dt2
            dt2.addToDecoders(d)
        }

        dt2.updateRemainingStock()

        let dt3 = DecoderType(entity: DecoderType.entity(), insertInto: nil)
        dt3.manufacturer = "ESU"
        dt3.productCode = "58828"
        dt3.productFamily = "LokSound 5 micro DCC"
        dt3.socket = "Next18"
        dt3.minimumStock = 0

        return Group {
            DecoderTypeRow(decoderType: dt)

            DecoderTypeRow(decoderType: dt2)

            DecoderTypeRow(decoderType: dt3)
            ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                DecoderTypeRow(decoderType: dt)
                    .environment(\.sizeCategory, item)
            }

            DecoderTypeRow(decoderType: dt)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 320, alignment: .leading)
        .previewLayout(.sizeThatFits)
    }
}
#endif
