//
//  ContentView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/22/20.
//

import SwiftUI

enum NavigationItem {
    case purchases
    case trains
}

struct ContentView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif

    @State var selection: NavigationItem = .trains

    @ViewBuilder var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            AppTabNavigation(selection: $selection)
        } else {
            AppSidebarNavigation(selection: $selection)
        }
        #elseif os(macOS)
        AppSidebarNavigation(selection: $selection)
            .frame(minWidth: 900, maxWidth: .infinity,
                   minHeight: 500, maxHeight: .infinity)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
