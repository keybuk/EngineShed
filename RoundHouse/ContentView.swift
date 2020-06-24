//
//  ContentView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/22/20.
//

import SwiftUI

struct ContentView: View {
    @ViewBuilder var body: some View {
        #if os(iOS)
        AppSidebarNavigation()
        #elseif os(macOS)
        AppSidebarNavigation()
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
