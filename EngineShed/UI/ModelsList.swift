//
//  ModelsList.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

import Database

struct ModelsList : View {
    var classification: Model.Classification?
    var sort: Model.Sort = .modelClass

    @FetchRequest(fetchRequest: Model.fetchRequestForModels(classification: nil, sortedBy: .modelClass))
    var models: FetchedResults<Model>

    var body: some View {
        List(models) { model in
            ModelRow(model: model)
        }
    }
}

#if DEBUG
struct ModelsList_Previews : PreviewProvider {
    static var previews: some View {
        ModelsList()
            .environment(\.managedObjectContext, previewData.container.viewContext)
    }
}
#endif
