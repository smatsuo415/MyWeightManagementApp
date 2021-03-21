//
//  MyWeightManagementAppApp.swift
//  MyWeightManagementApp
//
//  Created by Shugo Matsuo on 2021/03/21.
//

import SwiftUI

@main
struct MyWeightManagementAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
