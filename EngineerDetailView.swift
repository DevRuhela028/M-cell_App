import SwiftUI

struct EngineerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var engineer: Engineer
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Content Sections
                    VStack(spacing: 24) {
                        workloadSection
                        Divider()
                        skillsSection
                        Divider()
                        projectsSection
                        Divider()
                        contactSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Engineer Profile")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action for contacting
                        print("Contact \(engineer.name)")
                    } label: {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Background cover
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.7), .blue.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 150)
            
            // Profile info
            HStack(spacing: 24) {
                // Avatar
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .overlay(
                        Text(String(engineer.name.capitalized.prefix(1)))
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.blue)
                    )
                
                // Name & title
                VStack(alignment: .leading, spacing: 8) {
                    Text(engineer.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(engineer.specialization)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Status badge
                    Text(engineer.status)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.3))
                        )
                        .foregroundColor(statusColor)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            .padding(.top, 50)
            .background(
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.0), .blue.opacity(0.6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(height: 100)
                    .offset(y: 50)
            )
        }
    }
    
    // MARK: - Workload Section
    private var workloadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Current Workload")
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(Int(min(CGFloat(engineer.engineer_id) * 10, 100)))%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(workloadColor)
                    
                    Spacer()
                    
                    Text(workloadStatus)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(workloadColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        // Foreground
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: geometry.size.width * min(CGFloat(engineer.engineer_id) * 10, 100) / 100, height: 12)
                            .foregroundColor(workloadColor)
                    }
                }
                .frame(height: 12)
            }
            
            HStack {
                infoBox(title: "Tasks", value: "\(engineer.engineer_id + 3)")
                infoBox(title: "Projects", value: "\(engineer.engineer_id % 3 + 1)")
                infoBox(title: "Utilization", value: "\(Int(min(CGFloat(engineer.engineer_id) * 10, 100)))%")
            }
        }
    }
    
    // MARK: - Skills Section
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Skills & Expertise")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(getSkills(), id: \.self) { skill in
                    skillBadge(skill)
                }
            }
            
            Text("Experience Level: \(experienceLevel)")
                .font(.subheadline)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Projects Section
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Current Projects")
            
            ForEach(0..<(engineer.engineer_id % 3 + 1), id: \.self) { index in
                projectCard(
                    name: "Project \(projectNames[index % projectNames.count])",
                    description: "Working on \(projectDescriptions[index % projectDescriptions.count])",
                    progress: Double(30 + (index * 20))
                )
            }
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Contact Information")
            
            VStack(spacing: 16) {
                contactRow(icon: "envelope.fill", title: "Email", value: "\(engineer.name.lowercased().replacingOccurrences(of: " ", with: "."))@company.com")
                contactRow(icon: "phone.fill", title: "Phone", value: "+1 (555) \(100 + engineer.engineer_id * 111)-\(1000 + engineer.engineer_id * 111)")
                contactRow(icon: "building.2.fill", title: "Department", value: getDepartment())
                contactRow(icon: "calendar", title: "Availability", value: getAvailability())
            }
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private func infoBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func skillBadge(_ skill: String) -> some View {
        Text(skill)
            .font(.footnote)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
    }
    
    private func projectCard(name: String, description: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.system(size: 17, weight: .semibold))
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("\(Int(progress))%")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: geometry.size.width * progress / 100, height: 8)
                            .foregroundColor(.blue)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func contactRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 28, height: 28)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16))
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    private var statusColor: Color {
        switch engineer.status.lowercased() {
        case "busy": return .orange
        case "available": return .green
        default: return .blue
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
    
    private var workloadStatus: String {
        let workload = CGFloat(engineer.engineer_id) * 10
        if workload < 30 {
            return "Low Workload"
        } else if workload < 70 {
            return "Moderate Workload"
        } else {
            return "High Workload"
        }
    }
    
    private func getSkills() -> [String] {
        let allSkills = [
            "Swift", "SwiftUI", "UIKit", "Objective-C", "Kotlin", 
            "Java", "Python", "JavaScript", "TypeScript", "React",
            "Angular", "Vue", "Node.js", "C#", "C++", 
            "AWS", "Azure", "GCP", "Docker", "Kubernetes",
            "CI/CD", "Git", "SQL", "NoSQL", "Agile"
        ]
        
        var skills = [String]()
        // Generate 4-7 random skills based on engineer_id
        let numSkills = 4 + (engineer.engineer_id % 4)
        for i in 0..<numSkills {
            let index = (engineer.engineer_id * 3 + i) % allSkills.count
            skills.append(allSkills[index])
        }
        
        // Always add the specialization if it's not already included
        if !skills.contains(engineer.specialization) && !engineer.specialization.isEmpty {
            skills.append(engineer.specialization)
        }
        
        return skills
    }
    
    private var experienceLevel: String {
        let levels = ["Junior", "Mid-level", "Senior", "Principal", "Staff"]
        return levels[min(engineer.engineer_id % levels.count, levels.count - 1)]
    }
    
    private func getDepartment() -> String {
        let departments = ["Engineering", "Product Development", "R&D", "Infrastructure", "Mobile Applications"]
        return departments[min(engineer.engineer_id % departments.count, departments.count - 1)]
    }
    
    private func getAvailability() -> String {
        if engineer.status.lowercased() == "busy" {
            return "Available in \(2 + (engineer.engineer_id % 3)) weeks"
        } else {
            return "Available now"
        }
    }
    
    // Sample project data
    private let projectNames = [
        "Atlas", "Phoenix", "Horizon", "Meridian", "Quantum", 
        "Nova", "Titan", "Olympus", "Voyager", "Nebula"
    ]
    
    private let projectDescriptions = [
        "feature development", "UI enhancements", "performance optimization",
        "backend integration", "system architecture", "security improvements",
        "cross-platform compatibility", "API development", "data migration",
        "cloud infrastructure"
    ]
}

