import SwiftUI
import UniformTypeIdentifiers
import Supabase
import Auth
import PDFKit

struct ResumeView: View {
    @StateObject private var resumeViewModel = ResumeViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showAddResume = false
    @State private var userId: UUID?
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Section
                Section {
                    if profileViewModel.isLoading {
                        ProgressView()
                    } else if profileViewModel.isEditing {
                        ProfileEditView(viewModel: profileViewModel, userId: userId)
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
                
                // MARK: - Resumes Section
                Section {
                    if resumeViewModel.isLoading {
                        ProgressView()
                    } else if resumeViewModel.resumes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                            Text("No resumes yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button("Upload Resume") {
                                showAddResume = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
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
                        if resumeViewModel.resumes.isEmpty {
                            Button {
                                showAddResume = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        } else {
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
            .sheet(isPresented: $showAddResume) {
                AddResumeView(viewModel: resumeViewModel, userId: userId)
            }
            .task {
                if let session = try? await supabase.auth.session,
                   let uuid = UUID(uuidString: session.user.id.uuidString) {
                    userId = uuid
                    await profileViewModel.fetchProfile(userId: uuid)
                    await resumeViewModel.fetchResumes(userId: uuid)
                }
            }
        }
    }
}

// MARK: - Profile Read View
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

// MARK: - Profile Row
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

// MARK: - Profile Edit View
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
                if profileViewModel_hasProfile {
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
                .disabled(viewModel.fullName.isEmpty || viewModel.isSaving)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var profileViewModel_hasProfile: Bool {
        viewModel.profile != nil
    }
}

// MARK: - Resume Row View
struct ResumeRowView: View {
    let resume: Resume
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(resume.title)
                    .font(.headline)
                Text("Uploaded \(resume.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Menu {
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Resume View
struct AddResumeView: View {
    @ObservedObject var viewModel: ResumeViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var rawText = ""
    @State private var showFilePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section("Resume Title") {
                    TextField("e.g. iOS Developer CV", text: $title)
                }

                Section("Content") {
                    Button {
                        showFilePicker = true
                    } label: {
                        Label("Import from PDF", systemImage: "doc.fill")
                    }

                    if !rawText.isEmpty {
                        Text("✓ Text extracted (\(rawText.count) chars)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }

                    TextEditor(text: $rawText)
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if rawText.isEmpty {
                                    Text("Or paste resume text here...")
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Resume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            if let userId {
                                await viewModel.saveResume(
                                    userId: userId,
                                    title: title.isEmpty ? "My Resume" : title,
                                    rawText: rawText,
                                    isDefault: true  // всегда true для MVP
                                )
                            }
                        }
                    }
                    .disabled(rawText.isEmpty || viewModel.isLoading)
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                if let url = try? result.get().first {
                    extractText(from: url)
                }
            }
        }
    }

    private func extractText(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        if let pdf = PDFDocument(url: url) {
            var text = ""
            for i in 0..<pdf.pageCount {
                if let page = pdf.page(at: i) {
                    text += (page.string ?? "") + "\n"
                }
            }
            rawText = text
        }
    }
}

#Preview {
    ResumeView()
}
