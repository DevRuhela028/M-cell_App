// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @StateObject private var authStore = AuthStore()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if authStore.isCheckingAuth {
                    ProgressView("Checking authentication...")
                } else if authStore.isAuthenticated {
                    // Navigate to correct dashboard automatically
                    switch authStore.user?.role {
                    case "student":
                        StudentDashboard(path: $path)
                    case "admin":
                        AdminDashboard(path: $path)
                    case "engineer":
                        EngineerDashboard(path: $path)
                    default:
                        LandingPage(path: $path)
                    }
                } else {
                    LandingPage(path: $path)
                }
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .login:
                    LoginView(path: $path)
                case .signup:
                    SignupView(path: $path)
                case .adminDashboard:
                    AdminDashboard(path: $path)
                case .studentDashboard:
                    StudentDashboard(path: $path)
                case .engineerDashboard:
                    EngineerDashboard(path: $path)
                }
            }
        }
        .environmentObject(authStore)
        .onAppear {
            Task {
                await authStore.checkAuth() // Check auth on app start
            }
            
        }
    }
}

#Preview {
    ContentView()
}
