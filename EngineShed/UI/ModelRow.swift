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
            RowImage(image: Image(uiImage: model.image!))

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
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            List {
                ForEach(previewData.models, id: \.objectID) { model in
                    ModelRow(model: model)
                }

                ForEach(ContentSizeCategory.other, id: \.self) { item in
                    ModelRow(model: previewData.models.first!)
                        .environment(\.sizeCategory, item)
                }
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
