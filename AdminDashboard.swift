import SwiftUI

struct ActionCard: Identifiable {
    let id = UUID()
    let title: String
    let value: Int
    let logo: Image
    let logoColor: Color
}

// har tab ke item ka khud ka navigation view mai wrap krna hai issi file mai

struct AdminDashboard: View {
    @EnvironmentObject var authStore: AuthStore
    @Binding var path: NavigationPath
    @State var BGcolor: LinearGradient = LinearGradient(colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
    @State var ActionCards: [ActionCard] = [
        ActionCard(title: "Total Complaints", value: 128, logo: Image(systemName: "pencil"), logoColor: Color.blue),
        ActionCard(title: "Active Engineers", value: 24, logo: Image(systemName: "person.fill"), logoColor: Color.red),
        ActionCard(title: "Pending Complaints", value: 18, logo: Image(systemName: "clock.fill"), logoColor: Color.yellow),
        ActionCard(title: "Resolution Rate", value: 86, logo: Image(systemName: "chart.bar.fill"), logoColor: Color.green)
    ]
    
    var body: some View {
        TabView {
            // Dashboard Tab - with its own NavigationView
            
            DashboardSectionContent()
                .environmentObject(authStore)
                .tabItem {
                    VStack {
                        Image(systemName:"house.fill")
                        Text("Dashboard")
                    }
                }
            
            
        
            EngineerSectionContent()
                .environmentObject(authStore)
                .tabItem {
                    VStack {
                        Image(systemName: "person.3.fill")
                        Text("Engineers")
                    }
                }
            
            // Complaints Tab - with its own NavigationView
            
            ComplaintSectionContent()
                .environmentObject(authStore)
                .tabItem {
                    VStack {
                        Image(systemName: "exclamationmark.bubble.fill")
                        Text("Complaints")
                    }
                }
            
            // Analytics Tab - with its own NavigationView
//            NavigationView {
//                ZStack {
//                    BGcolor.ignoresSafeArea()
//                    Text("Analytics Screen")
//                }
//                .navigationBarTitle("Analytics", displayMode: .large)
//                .navigationBarItems(leading:
//                    Image("Logo")
//                        .resizable()
//                        .frame(width: 35, height: 35)
//                        .padding(.bottom, 5)
//                )
//            }
//            .tabItem {
//                VStack {
//                    Image(systemName: "chart.bar.xaxis")
//                    Text("Analytics")
//                }
//            }
        }
    }
}


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


#Preview {
    AdminDashboard(path: .constant(NavigationPath()))
        .environmentObject(AuthStore())
}
