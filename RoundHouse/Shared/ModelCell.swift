//
//  ModelCell.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

import Database

struct ModelCell: View {
    var model: Model

    var body: some View {
        HStack {
            RowImage(image: Image(uiImage: model.image!))

            VStack(alignment: .leading) {
                if let wheelArrangement = model.wheelArrangement {
                    Text ("\(model.modelClass!) \(wheelArrangement)")
                        .font(.caption)
                } else {
                    Text(model.modelClass!)
                        .font(.caption)
                }
                Text(model.number!)
                    .font(.headline)
                Text(model.name!)
            }
        }
    }
}

struct ModelCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ModelCell(model: previewData.models.first!)
        }
    }
}
