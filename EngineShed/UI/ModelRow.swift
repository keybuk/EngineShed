//
//  ModelRow.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct ModelRow : View {

    var model: Model

    var body: some View {
        HStack {
            Image(uiImage: model.image!)
                .resizable()
                .frame(width: 100)
                .aspectRatio(16/9, contentMode: .fit)
                .background(Color.white)
                .cornerRadius(4)
                .padding([.leading, .top, .bottom], 2)

            VStack(alignment: .leading) {
                Text(model.modelClass!)
                    .font(.caption)
                Text(model.number!)
                    .font(.headline)
                Text(model.name!)
            }
        }
    }
    
}

#if DEBUG
struct ModelRow_Previews : PreviewProvider {
    static var previews: some View {
        return Group {
            ForEach(previewData.models.identified(by: \.objectID)) { model in
                ModelRow(model: model)
            }

            ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                ModelRow(model: previewData.models.first!)
                    .environment(\.sizeCategory, item)
            }

            ModelRow(model: previewData.models.first!)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 320, alignment: .leading)
        .previewLayout(.sizeThatFits)
    }
}
#endif
