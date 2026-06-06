import SwiftUI

struct ResumeView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var resumeViewModel = ResumeViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showAddResume = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if profileViewModel.isLoading {
                        ProgressView()
                    } else if profileViewModel.isEditing {
                        ProfileEditView(viewModel: profileViewModel, userId: auth.currentUserId)
                    } else if let profile = profileViewModel.profile {
                        ProfileReadView(profile: profile) {
                            profileViewModel.startEditing()
                        }
                    } else {
                        Button {
                            profileViewModel.isEditing = true
                        } label: {
                            Label("Complete your profile", systemImage: "person.crop.circle.badge.plus")
                        }
                    }
                } header: {
                    Text("About me")
                }
                
                Section {
                    if resumeViewModel.isLoading {
                        ProgressView()
                    } else if resumeViewModel.resumes.isEmpty {
                        Button {
                            showAddResume = true
                        } label: {
                            Label("Upload Resume", systemImage: "doc.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 4)
                    } else {
                        ForEach(resumeViewModel.resumes) { resume in
                            ResumeRowView(resume: resume) {
                                Task { await resumeViewModel.deleteResume(resume: resume) }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("My Resume")
                        Spacer()
                        if !resumeViewModel.resumes.isEmpty {
                            Button("Update") {
                                showAddResume = true
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        Task { await auth.signOut() }
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showAddResume) {
                AddResumeView(viewModel: resumeViewModel, userId: auth.currentUserId)
            }
            .task {
                if let userId = auth.currentUserId {
                    await profileViewModel.fetchProfile(userId: userId)
                    await resumeViewModel.fetchResumes(userId: userId)
                }
            }
        }
    }
}

struct ProfileReadView: View {
    let profile: UserProfile
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName ?? "Add your name")
                        .font(.headline)
                    if let headline = profile.headline, !headline.isEmpty {
                        Text(headline)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button("Edit", action: onEdit)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if let important = profile.importantInCompany, !important.isEmpty {
                ProfileRow(icon: "building.2", label: "Important in company", value: important)
            }
            if let workStyle = profile.workStyle, !workStyle.isEmpty {
                ProfileRow(icon: "laptopcomputer", label: "Work style", value: workStyle)
            }
            if let goals = profile.careerGoals, !goals.isEmpty {
                ProfileRow(icon: "target", label: "Career goals", value: goals)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProfileRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let userId: UUID?
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Full name", text: $viewModel.fullName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Headline (e.g. iOS Developer)", text: $viewModel.headline)
                .textFieldStyle(.roundedBorder)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("What's important to you in a company?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $viewModel.importantInCompany)
                    .frame(minHeight: 80)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Work style preferences")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("e.g. remote, small team, async", text: $viewModel.workStyle)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Career goals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $viewModel.careerGoals)
                    .frame(minHeight: 80)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack {
                if viewModel.profile != nil {
                    Button("Cancel") {
                        viewModel.isEditing = false
                    }
                    .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    Task {
                        if let userId {
                            await viewModel.saveProfile(userId: userId)
                        }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.fullName.isEmpty || viewModel.isSaving || userId == nil)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ResumeView()
        .environmentObject(AuthViewModel())
}
