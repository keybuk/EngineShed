//
//  Sidebar.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/22/20.
//

import SwiftUI

struct AppSidebar: View {
    @Binding var selection: NavigationItem

    var body: some View {
        // Wrap the Binding to an Optional.
        List(selection: Binding($selection)) {
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
        AppSidebar(selection: .constant(.trains))
    }
}
