//
//  AppTabNavigation.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI

struct AppTabNavigation: View {
    enum NavigationItem {
        case purchases
        case trains
    }

    @State var selection: NavigationItem = .trains

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                PurchasesView()
            }
            .tabItem {
                Label("Purchases", systemImage: "bag")
                    .accessibility(label: Text("Purchases"))
            }
            .tag(NavigationItem.purchases)

            NavigationView {
                TrainsView()
            }
            .tabItem {
                Label("Trains", systemImage: "tram.fill")
                    .accessibility(label: Text("Trains"))
            }
            .tag(NavigationItem.trains)
        }
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppTabNavigation()
    }
}
