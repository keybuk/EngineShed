//
//  TrainHeader.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI

import Database

struct TrainHeader: View {
    @ObservedObject var train: Train

    var body: some View {
        VStack(alignment: .leading) {
            if let name = train.name, let number = train.number {
                Text("\(number) — \(name)")
                    .font(.headline)
            } else if let number = train.number {
                Text(number)
                    .font(.headline)
            } else if let name = train.name {
                Text(name)
                    .font(.headline)
            } else {
                Text("??")
            }

            if let details = train.details {
                Text("\(details)")
                    .font(.subheadline)
            }
        }
    }
}

struct TrainHeader_Previews: PreviewProvider {
    static var previews: some View {
        List {
            // Named train with details.
            TrainHeader(train: previewContent.trains["The Flying Scotsman"]!)

            // Numbered train
            TrainHeader(train: previewContent.trains["800010"]!)
        }
    }
}
