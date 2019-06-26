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
                .aspectRatio(contentMode: .fit)
                .cornerRadius(4)
                .padding(2)
                .frame(width: 100)
                .aspectRatio(16/9, contentMode: .fit)

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
fileprivate extension ContentSizeCategory {

    static let other: [ContentSizeCategory] = [.large, .extraSmall, .extraLarge]

}

struct ModelRow_Previews : PreviewProvider {
    static var previews: some View {
        let m = Model(entity: Model.entity(), insertInto: nil)
        m.image = UIImage(named: "R3612")
        m.modelClass = "LNER Gresley 'A4' 4-6-2"
        m.number = "4468"
        m.name = "Mallard"

        return Group {
            ModelRow(model: m)

            ForEach(ContentSizeCategory.other.identified(by: \.self)) { item in
                ModelRow(model: m)
                    .environment(\.sizeCategory, item)
            }

            ModelRow(model: m)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 320, alignment: .leading)
        .previewLayout(.sizeThatFits)
    }
}
#endif
