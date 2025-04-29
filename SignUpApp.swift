//
//  SignupApp.swift
//  Signup
//
//  Created by Dev Ruhela on 25/04/25.
//

//this is the main file
import SwiftUI

@main
struct SignupApp: App {
    @StateObject private var authStore = AuthStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authStore)
                .task {
                    await authStore.checkAuth()
                }
        }
    }
}

