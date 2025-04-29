// AuthStore.swift

import Foundation
import Combine
import SwiftUI

// MARK: - Models
struct User: Codable {
    let id: Int        // Note: changed from String to Int because backend sends id=3
    let name: String
    let email: String
    let role: String
    let roll: String?          // for students
    let specialization: String? //  for engineers
}

//swift will only decode what you ask for
struct Engineer: Codable, Identifiable , Equatable {
    let engineer_id: Int
    let name: String
    let email: String
    let specialization: String
    let status: String
    let contact : String?
    var id: Int { engineer_id }
}

//engnieers must be matched from backend response
struct EngineersResponse  : Decodable{
    let engineers : [Engineer]
}

struct Complaint:Codable , Identifiable {
    let complaint_id :Int
    let subject: String
    let description : String
    let status : String
    let email : String
    let created_at : String
    let priority: String
    let hostel_no : String
    let phone_no : String
    let room_no : String
    var id: Int {complaint_id}
}

struct ComplaintResponse : Decodable {
    let complaints : [Complaint]
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let user: User?
}

// MARK: - AuthStore
class AuthStore: ObservableObject {
    // Published state
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var isCheckingAuth = true
    @Published var error: String?
    @Published var Engineers: [Engineer] = []
    @Published var Complaints : [Complaint] = []

    
    // Toast
    @Published var showToast = false
    @Published var toastMessage = ""
    
    private let apiURL = "http://172.20.10.3:8000/api/auth"

    //engineer preview data
    func EngineerPreviewData() {
        self.Engineers = [
            Engineer(engineer_id: 1, name: "John Doe", email: "john@example.com", specialization: "Electrical", status: "Available" , contact:"7302611179"),
            Engineer(engineer_id: 2, name: "Jane Smith", email: "jane@example.com", specialization: "Plumbing", status: "Busy",contact:"7302611179"),
            Engineer(engineer_id: 3, name: "Mike Johnson", email: "mike@example.com", specialization: "Internet", status: "Available",contact:"7302611179")
        ]
    }
    
    func ComplaintPreviewData() {
        self.Complaints = [
            Complaint(complaint_id: 1, subject: "electrical", description: "lan not working", status: "In Progress", email: "dev.ruhela120@gmail.com" , created_at: "2025-04-26 14:23:45" , priority: "Medium" ,  hostel_no:"BH-3"  ,phone_no: "7302611179" , room_no: "747"),
            Complaint(complaint_id: 2, subject: "electrical", description: "lan not working", status: "Submitted", email: "dev.ruhela120@gmail.com" , created_at: "2025-04-26 14:23:45" , priority: "Medium" ,  hostel_no:"BH-3"  ,phone_no: "7302611179" , room_no: "747")
            
        ]
    }
    
    // to show for preview
    func isPreview() -> Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
    
    // MARK: - Signup
    func signup(name: String, email: String, password: String, role: String, roll: String?, specialization: String?) async {
        await setLoading(true)
        do {
            guard let url = URL(string: "\(apiURL)/signup") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any?] = [
                "name": name,
                "email": email,
                "password": password,
                "role": role,
                "roll": roll,
                "specialization": specialization
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })

            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            
            await handleAuthResponse(response, successMessage: "Signup successful")
        } catch {
            await handleError(error.localizedDescription)
        }
    }

    // MARK: - Login
    func login(email: String, password: String, role: String) async {
        await setLoading(true)
        do {
            
            guard let url = URL(string: "\(apiURL)/login") else { return }
            print("requested to : " ,url)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "email": email,
                "password": password,
                "role": role
            ]
            print("body of data sent :" ,body)
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, _) = try await URLSession.shared.data(for: request)
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No response")")
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            
            await handleAuthResponse(response, successMessage: "Login successful")
        } catch {
            await handleError(error.localizedDescription)
        }
    }

    // MARK: - Logout
    func logout() async {
        print("requested posted to logout")
        await setLoading(true)
        do {
            guard let url = URL(string: "\(apiURL)/logout") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let (_, _) = try await URLSession.shared.data(for: request)
            
            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
                self.isLoading = false
                self.showToast(message: "Logged out successfully")
                print(user ?? "no user",isAuthenticated)
            }
        } catch {
            await handleError("Error logging out")
        }
    }

    // MARK: - Check Auth
    func checkAuth() async {
        await setCheckingAuth(true)
        
        do {
            guard let url = URL(string: "\(apiURL)/check-auth") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)

            await MainActor.run {
                self.isCheckingAuth = false
                if response.success, let user = response.user {
                    self.user = user
                    self.isAuthenticated = true
                } else {
                    self.user = nil
                    self.isAuthenticated = false
                }
            }
        } catch {
            await MainActor.run {
                self.isCheckingAuth = false
                self.user = nil
                self.isAuthenticated = false
            }
        }
    }

    // MARK: - Helpers
    private func setLoading(_ loading: Bool) async {
        await MainActor.run {
            self.isLoading = loading
            self.error = nil
        }
    }

    private func setCheckingAuth(_ checking: Bool) async {
        await MainActor.run {
            self.isCheckingAuth = checking
            self.error = nil
        }
    }

    private func handleAuthResponse(_ response: AuthResponse, successMessage: String) async {
        await MainActor.run {
            self.isLoading = false
            if response.success, let user = response.user {
                self.user = user
                self.isAuthenticated = true
                self.showToast(message: successMessage)
            } else {
                self.error = response.message ?? "Authentication failed"
                self.showToast(message: self.error!)
            }
        }
    }

    private func handleError(_ message: String) async {
        await MainActor.run {
            self.isLoading = false
            self.error = message
            self.showToast(message: message)
        }
    }

    private func showToast(message: String) {
        self.toastMessage = message
        self.showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showToast = false
            self.toastMessage = ""
        }
    }
    

    func getAllEngineersForAdmin() async {
        print("i was called from app")
        
        do {
            guard let url = URL(string: "\(apiURL)/admin/engineers") else { return }
            print("request sent to : " , url)
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(EngineersResponse.self, from: data)
//            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No response")")
            await MainActor.run {
                self.Engineers = decoded.engineers
            }
        } catch {
            print("no data found")
            await MainActor.run {
                self.showToast(message: "Failed to fetch engineers")
            }
        }
    }
    
    func getAllComplainsForAdmin() async {
        print("i was called")
        
        do {
            guard let url = URL(string: "\(apiURL)/admin/complaints") else { return }
            print("request sent to : " , url)
            let (data, _) = try await URLSession.shared.data(from: url)
            print("data" , data)
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No response")")
            let decoded = try JSONDecoder().decode(ComplaintResponse.self, from: data)
            await MainActor.run {
                self.Complaints = decoded.complaints
                
            }
        } catch {
            
            await MainActor.run {
                self.showToast(message: "Failed to fetch engineers")
            }
        }
    }

}
