//
//  TrainsView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/22/20.
//

import SwiftUI

import Database

struct TrainsView: View {
    var body: some View {
        TrainList(fetchRequest: Train.fetchRequestForTrains())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TrainsView_Previews: PreviewProvider {
    static var previews: some View {
        TrainsView()
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
