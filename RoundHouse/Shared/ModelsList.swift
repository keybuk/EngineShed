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

struct ModelsList: View {
    var classification: Model.Classification?
    var sort: Model.Sort

    @FetchRequest
    var models: FetchedResults<Model>

    init(classification: Model.Classification? = nil, sort: Model.Sort = .modelClass) {
        self.classification = classification
        self.sort = sort
        
        _models = FetchRequest(fetchRequest: Model.fetchRequestForModels(classification: classification, sortedBy: sort))
    }

    var body: some View {
        List(models) { model in
            ModelCell(model: model)
        }
    }
}

struct ModelsList_Previews: PreviewProvider {
    static var previews: some View {
        ModelsList()
            .environment(\.managedObjectContext, previewData.container.viewContext)
    }
}
