//
//  PurchasesList.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

import Database

extension Purchase : Identifiable {}

struct PurchasesList : View {
    var sort: Purchase.Sort = .date

    @FetchRequest(fetchRequest: Purchase.fetchRequestForPurchases(sortedBy: .date))
    var purchases: FetchedResults<Purchase>

    var body: some View {
        List(purchases) { purchase in
            PurchaseRow(purchase: purchase)
        }
    }
}

#if DEBUG
struct PurchasesList_Previews : PreviewProvider {
    static var previews: some View {
        PurchasesList()
            .environment(\.managedObjectContext, previewData.container.viewContext)
    }
}
#endif
