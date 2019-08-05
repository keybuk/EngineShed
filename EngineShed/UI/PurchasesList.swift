//
//  PurchasesList.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

extension Purchase : Identifiable {}

struct PurchasesList : View {
    var ordering: PurchaseOrdering = .date

    @FetchRequest(fetchRequest: Purchase.fetchRequestForPurchases(orderingBy: .date))
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
