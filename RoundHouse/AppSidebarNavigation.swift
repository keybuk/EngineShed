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
            AppSidebar()
            Text("Select a category")
        }
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
    }
}
