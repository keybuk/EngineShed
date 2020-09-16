//
//  DecoderTypesList.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

import Database

struct DecoderTypesList : View {
    @FetchRequest(fetchRequest: DecoderType.fetchRequestForDecoderTypes())
    var decoderTypes: FetchedResults<DecoderType>

    var body: some View {
        List(decoderTypes) { decoderType in
            DecoderTypeRow(decoderType: decoderType)
        }
    }
}

#if DEBUG
struct DecoderTypesList_Previews : PreviewProvider {
    static var previews: some View {
        DecoderTypesList()
            .environment(\.managedObjectContext, previewData.container.viewContext)
    }
}
#endif
