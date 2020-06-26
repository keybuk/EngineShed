//
//  AppSidebarNavigation.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI

struct AppSidebarNavigation: View {
    @Binding var selection: NavigationItem

    var body: some View {
        NavigationView {
            #if os(iOS)
            AppSidebar(selection: $selection)
            #elseif os(macOS)
            AppSidebar(selection: $selection)
                .frame(minWidth: 100, idealWidth: 150, maxWidth: 200,
                       maxHeight: .infinity)
            #endif

            Text("Select a category")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation(selection: .constant(.trains))
    }
}
