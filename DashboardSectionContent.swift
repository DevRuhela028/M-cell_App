//
//  DashboardSectionContent.swift
//  Signup
//
//  Created by Dev Ruhela on 29/04/25.
//

import SwiftUI

struct DashboardSectionContent: View {
    @EnvironmentObject var authStore: AuthStore
    @State var BGcolor: LinearGradient = LinearGradient(colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
    @State var ActionCards: [ActionCard] = [
        ActionCard(title: "Total Complaints", value: 128, logo: Image(systemName: "pencil"), logoColor: Color.blue),
        ActionCard(title: "Active Engineers", value: 24, logo: Image(systemName: "person.fill"), logoColor: Color.red),
        ActionCard(title: "Pending Complaints", value: 18, logo: Image(systemName: "clock.fill"), logoColor: Color.yellow),
        ActionCard(title: "Resolution Rate", value: 86, logo: Image(systemName: "chart.bar.fill"), logoColor: Color.green)
    ]
    var body: some View {
        NavigationView {
            ZStack {
                BGcolor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Welcome back, Admin 👋")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Here's what's happening today")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(ActionCards) { actionCard in
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            Text(actionCard.title)
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(actionCard.logoColor.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    actionCard.logo
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(actionCard.logoColor)
                                                        .padding(10)
                                                )
                                        }
                                        Text("\(actionCard.value)")
                                            .font(.title)
                                            .bold()
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 140)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                }
                            }
                            .padding(.horizontal)
                            
                            SectionHeader(title: "Available Engineers")
                            
                            if !authStore.Engineers.isEmpty {
                                VStack(spacing: 15) {
                                    ForEach(authStore.Engineers.prefix(1)) { engineer in
                                        engineerCard(engineer: engineer)
                                    }
                                }
                            } else {
                                Text("No engineers available")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            
                            SectionHeader(title: "Recent Complaints")
                            
                            if !authStore.Complaints.isEmpty {
                                VStack(spacing: 15) {
                                    ForEach(authStore.Complaints.prefix(3)) { complaint in
                                        complaintCard(complaint: complaint)
                                    }
                                }
                            } else {
                                Text("No complaints available")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                    }
                    .padding(.top)
                }
                .navigationBarTitle("Admin Dashboard", displayMode: .large)
                .navigationBarItems(leading:
                    Image("Logo")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.bottom, 5)
                )
                .task {
                    await refreshData()
                }
                .refreshable {
                    await refreshData()
                }
            }
            
        }
        
    }
    func refreshData() async {
        if authStore.isPreview() {
            authStore.EngineerPreviewData()
            authStore.ComplaintPreviewData()
        } else {
            await authStore.getAllEngineersForAdmin()
            await authStore.getAllComplainsForAdmin()
        }
    }
    //cannot return as text because after applying background it is no longer a text , it is a modified view , so return as view
    func priorityBadge(priority: String) -> some View {
        var bgcolor: Color = Color.red
        if priority == "Low" {
            bgcolor = Color.green
        } else if priority == "Medium" {
            bgcolor = Color.orange
        }
        
        return Text(priority)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgcolor.opacity(0.2))
            )
            .foregroundColor(bgcolor)
    }

    func statusBadge(status : String) -> some View {
        var stat = status
        var bgColor: Color = Color.red
        if(status == "Assigned") {
            bgColor = Color.blue
        } else if(status == "In Progress") {
            bgColor = Color.orange
        } else if(status == "Under Review") {
            bgColor = Color.purple
        } else if(status == "Resolved") {
            bgColor = Color.green
        } else if(status == "Submitted") {
            bgColor = Color.yellow
            stat = "Unassigned"
        }
        
        return Text(stat)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor.opacity(0.2))
            )
            .foregroundColor(bgColor)
    }
    struct SectionHeader: View {
        var title: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("View all")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    func engineerCard(engineer: Engineer) -> some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(engineer.name.prefix(1)))
                        .font(.title3)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(engineer.name)
                    .font(.headline)
                
                Text(engineer.specialization)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(engineer.status)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(engineer.status == "Busy" ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                )
                .foregroundColor(engineer.status == "Busy" ? .orange : .green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    func complaintCard(complaint: Complaint) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("#C\(complaint.complaint_id) - \(complaint.subject)")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                priorityBadge(priority: "\(complaint.priority)")
            }
            
            Text("Submitted by \(complaint.email)")
                .font(.caption)
                .foregroundColor(.gray)
            HStack {
                statusBadge(status: "\(complaint.status)")
                Spacer()
                Text("Assign Engineer +")
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.vertical,8)
                    .background(Color.blue.cornerRadius(10))
                    .foregroundColor(Color.white)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
    
}

#Preview {
    DashboardSectionContent()
        .environmentObject(AuthStore())
}
