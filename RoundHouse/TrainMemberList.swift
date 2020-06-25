//
//  TrainMemberList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI
import CoreData

import Database

struct TrainMemberList: View {
    @FetchRequest
    var members: FetchedResults<TrainMember>

    init(fetchRequest: NSFetchRequest<TrainMember>) {
        _members = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(members) { member in
                    if let modelImage = member.model?.image {
                        modelImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    } else {
                        Text("??")
                    }
                }
            }
        }
    }
}

struct TrainMemberList_Previews: PreviewProvider {
    static var previews: some View {
        TrainMemberList(fetchRequest: previewContent.trains["The Flying Scotsman"]!.fetchRequestForMembers())
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
