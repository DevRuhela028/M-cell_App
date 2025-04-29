import SwiftUI

// This is the content portion of the complaint section without NavigationView

// Always wrap inside the navigation view instead of using navigation view to form the view itself

struct ComplaintSectionContent: View {
    @EnvironmentObject var authStore: AuthStore
    @State var BGcolor: LinearGradient = LinearGradient(colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
    @State var selectComplaint: String = "In Progress"
    @State private var selectedComplaint: Complaint? = nil
    
    var body: some View {
        ZStack {
            BGcolor.ignoresSafeArea(.all)
            VStack {
                VStack(alignment: .leading) {
                    Text("Manage and track all service complaints")
                        .font(.footnote)
                        .padding(.horizontal)
                        .padding(.top, -1)
                    HStack {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                        
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.horizontal)
                            .foregroundColor(.red)
                        Text("Apply Filters")
                            .padding(.leading,-15)
                            .font(.footnote)
                            .foregroundColor(Color.pink)
                        Spacer()
                        HStack {
                            
                            Picker("select complaint", selection: $selectComplaint) {
                                Text("All").tag("All")
                                Text("Unassigned").tag("Submitted")
                                Text("Declined").tag("Rejected")
                                Text("In Progress").tag("In Progress")
                                Text("Under Review").tag("Under Review")
                            }
                            .accentColor(Color.pink)
                            .pickerStyle(.menu)
                        }
                        .padding(.vertical,-4)
                        
                        
                        .background(Color.pink.opacity(0.2).cornerRadius(10))
                        .padding(.trailing)
                        .padding(.bottom,10)
                        .padding(.top,10)
                        
                    }
                    
                    
                    
                    ScrollView {
                        if !authStore.Complaints.isEmpty {
                            VStack(spacing: 15) {
                                ForEach(authStore.Complaints.filter { selectComplaint == "All" || $0.status == selectComplaint }) { complaint in
                                    complaintCard(complaint: complaint)
                                }
                            }
                            .id(selectComplaint) //  important: forces VStack to recognize change
                            .animation(.easeInOut, value: selectComplaint)
                        }
                        else {
                            Text("No complaints available")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .task {
                        await refreshData()
                    }
                    .refreshable {
                        await refreshData()
                    }
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedComplaint) { complaint in
            NavigationView { // Add NavigationView inside sheet
                ComplaintView(complaint: complaint)
                    .navigationBarTitle("Complaint #\(complaint.complaint_id)", displayMode: .inline)
            }
        }
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
                Button {
                    selectedComplaint = complaint
                } label: {
                    HStack(spacing: -4){
                        Text("Details")
                            .font(.subheadline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .foregroundColor(Color.blue)
                        
                        Image(systemName: "arrow.down.circle")
                            .frame(width: 4, height: 2)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    func refreshData() async {
        if authStore.isPreview() {
           
            authStore.ComplaintPreviewData()
        } else {
            
            await authStore.getAllComplainsForAdmin()
        }
    }
}

struct ComplaintView: View {
    let complaint: Complaint
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.04).ignoresSafeArea(.all)
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Description")
                            .foregroundColor(Color.black)
                            .fontWeight(.semibold)
                            .padding(.leading)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        statusBadge(status: "\(complaint.status)")
                            .padding(.top, 10)
                            .padding(.trailing, 10)
                    }
                    Text("\(complaint.description)")
                        .padding(.horizontal)
                        .foregroundColor(Color.black.opacity(0.5))
                    
                    HStack {
                        Text("Date of issuance")
                            .foregroundColor(Color.black)
                            .fontWeight(.semibold)
                            .padding(.leading)
                            .padding(.top, 20)
                        Spacer()
                    }
                    Text("\(complaint.created_at.prefix(11))")
                        .padding(.horizontal)
                        .foregroundColor(Color.black.opacity(0.5))
                    
                    HStack {
                        Text("Complainee")
                            .foregroundColor(Color.black)
                            .fontWeight(.semibold)
                            .padding(.leading)
                            .padding(.top, 20)
                        Spacer()
                    }
                    Text("Email: \(complaint.email)")
                        .padding(.horizontal)
                        .foregroundColor(Color.black.opacity(0.5))
                    Text("Contact: \(complaint.phone_no)")
                        .padding(.horizontal)
                        .foregroundColor(Color.black.opacity(0.5))
                    VStack {
                        HStack {
                            Text("Location")
                                .foregroundColor(Color.black)
                                .fontWeight(.semibold)
                                .padding(.leading)
                                .padding(.top, 20)
                            Spacer()
                            Text("Priority")
                                .foregroundColor(Color.black)
                                .fontWeight(.semibold)
                                .padding(.trailing)
                                .padding(.top, 20)
                        }
                        HStack {
                            Text("\(complaint.hostel_no), \(complaint.room_no)")
                                .foregroundColor(Color.black.opacity(0.5))
                                .padding(.top, -15)
                                .padding(.leading, 15)
                            Spacer()
                            priorityBadge(priority: "\(complaint.priority)")
                                .padding(.trailing)
                                .padding(.top, -8)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("Assign Engineer +")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue.cornerRadius(10))
                            .foregroundColor(Color.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

// Wrapper view for previews  
struct ComplaintSection: View {
    var body: some View {
        NavigationView {
            ComplaintSectionContent()
                .environmentObject(AuthStore())
                .navigationBarTitle("Complaints", displayMode: .large)
        }
    }
}

#Preview {
    ComplaintSection()
        .environmentObject(AuthStore())
}
