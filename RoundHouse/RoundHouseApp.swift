//
//  RoundHouseApp.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/22/20.
//

import SwiftUI

import Database

@main
struct RoundHouseApp: App {
    @StateObject var persistentContainer = PersistentContainer.loadDefaultStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
