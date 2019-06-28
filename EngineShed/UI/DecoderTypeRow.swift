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
        let isStockLow = decoderType.remainingStock < decoderType.minimumStock

        return HStack {
            Image("58419")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .aspectRatio(16/9, contentMode: .fit)
                .background(Color.white)
                .cornerRadius(4)
                .padding([.leading, .top, .bottom], 2)

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
                Spacer()
                Text("\(decoderType.remainingStock)")
                    .font(.callout)
                    .color(isStockLow ? Color("stockLowTextColor") : Color("stockNormalTextColor"))
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 4)
                    .background(Capsule().fill(isStockLow ? Color("stockLowColor") : Color("stockNormalColor")))
                    .padding([.leading, .trailing])
            }
        }
    }
}

#if DEBUG
struct DecoderTypeRow_Previews : PreviewProvider {
    static var previews: some View {
        return Group {
            ForEach(previewData.decoderTypes.identified(by: \.objectID)) { decoderType in
                DecoderTypeRow(decoderType: decoderType)
            }

            ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                DecoderTypeRow(decoderType: previewData.decoderTypes.first!)
                    .environment(\.sizeCategory, item)
            }

            DecoderTypeRow(decoderType: previewData.decoderTypes.first!)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 320, alignment: .leading)
        .previewLayout(.sizeThatFits)
    }
}
#endif
