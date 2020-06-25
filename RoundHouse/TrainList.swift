//
//  TrainList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI
import CoreData

import Database

struct TrainList: View {
    @FetchRequest
    var trains: FetchedResults<Train>

    init(fetchRequest: NSFetchRequest<Train>) {
        _trains = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        List {
            ForEach(trains) { train in
                VStack(alignment: .leading) {
                    TrainHeader(train: train)
                    TrainMemberList(fetchRequest: train.fetchRequestForMembers())
                }
            }
        }
    }
}

struct TrainList_Previews: PreviewProvider {
    static var previews: some View {
        TrainList(fetchRequest: Train.fetchRequestForTrains())
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
