//
//  Sidebar.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/22/20.
//

import SwiftUI

struct AppSidebar: View {
    enum NavigationItem {
        case purchases
        case trains
    }

    @State var selection: Set<NavigationItem> = [.trains]

    var body: some View {
        List(selection: $selection) {
            NavigationLink(
                destination: PurchasesView()) {
                Label("Purchases", systemImage: "bag")
            }
            .accessibility(label: Text("Purchases"))
            .tag(NavigationItem.purchases)

            NavigationLink(
                destination: TrainsView()) {
                Label("Trains", systemImage: "tram")
            }
            .accessibility(label: Text("Trains"))
            .tag(NavigationItem.trains)
        }
        .listStyle(SidebarListStyle())
    }
}

struct AppSidebar_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebar()
    }
}
