import SwiftUI

// This is the content portion of the engineer section without NavigationView
struct EngineerSectionContent: View {
    @EnvironmentObject var authStore: AuthStore
    @State var BGcolor: LinearGradient = LinearGradient(colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
    @State var engineerStatus: String = "All"
    @State var engineerSpec: String = "All"
    @State var searchEngineer: String = ""
    @State var selectedEngineer: Engineer? = nil
  
    
    var body: some View {
        ZStack {
            BGcolor.ignoresSafeArea(.all)
            VStack {
                VStack(alignment: .leading) {
                    Text("Manage your team of technical specialists")
                        .padding(.horizontal)
                    
                    TextField("Search Engineer", text: $searchEngineer)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        )
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))
                        .padding()
                
                    
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
                        HStack{
                            Picker("Status", selection: $engineerStatus) {
                                Text("Busy").tag("Busy")
                                Text("Available").tag("Available")
                                Text("All").tag("All")
                            }
                            .accentColor(Color.pink)
                            .pickerStyle(.menu)
                            
                            
                        }
                        .padding(.vertical,-4)
                        .background(Color.pink.opacity(0.2).cornerRadius(20))
                        .padding(.trailing,-5)
                        .padding(.bottom,10)
                        .padding(.top,10)
                        HStack{
                            
                            Picker("Specialization", selection: $engineerSpec) {
                                Text("Internet").tag("Internet")
                                Text("Furniture").tag("Furniture")
                                Text("Plumbing").tag("Plumbing")
                                Text("Other").tag("Other")
                                Text("All").tag("All")
                            }
                            .accentColor(Color.pink)
                            .pickerStyle(.menu)
                        }
                        
                        .padding(.vertical,-4)
                        .background(Color.pink.opacity(0.2).cornerRadius(20))
                        .padding(.trailing)
                        .padding(.bottom,10)
                        .padding(.top,10)
                        
                    }
                    
                    
                    ScrollView {
                        if !authStore.Engineers.isEmpty {
                            VStack(spacing: 15) {
                                ForEach(authStore.Engineers.filter { engineer in
                                    (engineerStatus == "All" || engineer.status == engineerStatus) &&
                                    (engineerSpec == "All" || engineer.specialization == engineerSpec)
                                }) { engineer in
                                    EngineerCard(engineer: engineer)
                                    
                                }
                            }
                            .id(engineerStatus + engineerSpec) // this forces animation when filters change and we can multiple of these
                            .animation(.easeInOut, value: engineerStatus + engineerSpec) // can add multiple elements while animating
                        } else {
                            Text("No engineers available")
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
    }
    
    struct EngineerCard: View {
        var engineer: Engineer
        @State private var showOptions = false
        @State private var selectedEngineer: Engineer?
        @State private var showEngineerDetails = false
        // Animation properties
        @Namespace private var animation
        @State private var isPressed = false
        
        var body: some View {
            VStack(spacing: 0) {
                // Main Card Content
                mainCardContent
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isPressed = false
                                }
                            }
                        }
                    }
                    .scaleEffect(isPressed ? 0.98 : 1)
                
                // Options Panel
                if showOptions {
                    optionsPanel
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showOptions)
        }
        
        // MARK: - Components
        
        private var mainCardContent: some View {
            HStack(spacing: 16) {
                // Avatar
                profileAvatar
                
                // Engineer Info
                engineerInfo
                
                Spacer()
                
                // Status Badge
                statusBadge
                
                // Options Button
                optionsButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        
        private var profileAvatar: some View {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(engineer.name.capitalized.prefix(1)))
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.blue)
                )
                .matchedGeometryEffect(id: "avatar", in: animation)
        }
        
        private var engineerInfo: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(engineer.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(engineer.specialization)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                workloadBar
            }
        }
        
        private var workloadBar: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Workload")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        // Foreground
                        Capsule()
                            .frame(width: min(CGFloat(engineer.engineer_id) * 10, geometry.size.width), height: 6)
                            .foregroundColor(workloadColor)
                    }
                }
                .frame(height: 6)
                .padding(.top, 2)
            }
        }
        
        private var workloadColor: Color {
            let workload = CGFloat(engineer.engineer_id) * 10
            if workload < 30 {
                return .green
            } else if workload < 70 {
                return .orange
            } else {
                return .red
            }
        }
        
        private var statusBadge: some View {
            Text(engineer.status)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                )
                .foregroundColor(statusColor)
        }
        
        private var statusColor: Color {
            switch engineer.status.lowercased() {
            case "busy": return .orange
            case "available": return .green
            default: return .blue
            }
        }
        
        private var optionsButton: some View {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showOptions.toggle()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary.opacity(0.7))
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(showOptions ? 0.2 : 0.0))
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .rotationEffect(Angle(degrees: showOptions ? 90 : 0))
        }
        
        private var optionsPanel: some View {
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    actionButton(
                        icon: "eye.fill",
                        text: "View Profile",
                        color: .blue
                    ) {
                        showEngineerDetails = true
                        selectedEngineer = engineer
                        print("View pressed for \(engineer.name)")
                    }
                    
                    Divider()
                        .padding(.horizontal)
                        .opacity(0.6)
                    
                    actionButton(
                        icon: "phone.fill",
                        text: "Contact",
                        color: .green
                    ) {
                        print("Contact pressed for \(engineer.name)")
                    }
                }
                .padding(.vertical, 8)
                .sheet(isPresented: $showEngineerDetails) {
                            EngineerDetailView(engineer: engineer)
                        }
            }
            .background(Color.gray.opacity(0.05))
        }
        
        private func actionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                    
                    Text(text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
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
}

// Wrapper view for previews
struct EngineerSection: View {
    var body: some View {
        NavigationView {
            EngineerSectionContent()
                .environmentObject(AuthStore())
                .navigationBarTitle("Engineers", displayMode: .large)
        }
    }
}

#Preview {
    EngineerSection()
        .environmentObject(AuthStore())
}
