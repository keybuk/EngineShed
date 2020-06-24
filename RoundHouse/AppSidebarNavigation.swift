//
//  AppSidebarNavigation.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/20.
//

import SwiftUI

struct AppSidebarNavigation: View {
    var body: some View {
        NavigationView {
            #if os(iOS)
            AppSidebar()
            #elseif os(macOS)
            AppSidebar()
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
        AppSidebarNavigation()
    }
}
