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
        HStack {
            RowImage(image: Image("58419"))

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

            if decoderType.minimumStock > 0 || decoderType.remainingStock > 0 {
                Spacer()
                DecoderTypeStock(decoderType: decoderType)
            }
        }
    }
    
}

struct DecoderTypeStock : View {

    var decoderType: DecoderType

    var body: some View {
        Text("\(decoderType.remainingStock)")
            .font(.callout)
            .color(Color(decoderType.isStockLow ? "stockLowTextColor" : "stockNormalTextColor"))
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 4)
            .background(Capsule().fill(Color(decoderType.isStockLow ? "stockLowColor" : "stockNormalColor")))
            .padding([.leading, .trailing])
    }

}

#if DEBUG
struct DecoderTypeRow_Previews : PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.identified(by: \.self)) { colorScheme in
            List {
                ForEach(previewData.decoderTypes.identified(by: \.objectID)) { decoderType in
                    DecoderTypeRow(decoderType: decoderType)
                }

                ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                    DecoderTypeRow(decoderType: previewData.decoderTypes.first!)
                        .environment(\.sizeCategory, item)
                }
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
