//
//  ResumeView.swift
//  MatchFlow
//

import SwiftUI

struct ResumeView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var resumeViewModel = ResumeViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showAddResume = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    AuthBackgroundView()
                    scrollContent(minHeight: geometry.size.height)
                    profileMenu
                }
                .ignoresSafeArea(edges: .top)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddResume) {
                AddResumeView(viewModel: resumeViewModel, userId: auth.currentUserId)
            }
            .sheet(isPresented: $profileViewModel.isEditing) {
                ProfileEditView(viewModel: profileViewModel, userId: auth.currentUserId)
                    .presentationDragIndicator(.visible)
            }
            .task {
                if let userId = auth.currentUserId {
                    await profileViewModel.fetchProfile(userId: userId)
                    if profileViewModel.profile == nil {
                        profileViewModel.isEditing = false
                    }
                    await resumeViewModel.fetchResumes(userId: userId)
                }
            }
        }
    }

    private func scrollContent(minHeight: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.s0) {
                if profileViewModel.isLoading {
                    ProgressView()
                        .padding(.top, DSSpacing.s116)
                } else {
                    ProfileHeaderView(profile: profileViewModel.profile)
                }

                ProfileResumeSection(
                    resumes: resumeViewModel.resumes,
                    isLoading: resumeViewModel.isLoading,
                    onUpdate: { showAddResume = true },
                    onUpload: { showAddResume = true },
                    onDelete: { resume in
                        Task { await resumeViewModel.deleteResume(resume: resume) }
                    }
                )
                .padding(.top, DSSpacing.s64)

                Spacer(minLength: DSSpacing.s64)
            }
            .padding(.horizontal, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s64)
            .frame(minHeight: minHeight, alignment: .top)
        }
        .contentMargins(.top, DSSpacing.s0, for: .scrollContent)
    }

    private var profileMenu: some View {
        VStack {
            HStack {
                Spacer()
                Menu {
                    Button("Edit Profile") {
                        profileViewModel.startEditing()
                    }
                    Button("Sign Out", role: .destructive) {
                        Task { await auth.signOut() }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.foregroundPrimary)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.top, DSSpacing.s62)
            .padding(.trailing, DSSpacing.s16)

            Spacer()
        }
    }
}

#Preview {
    ResumeView()
        .environmentObject(AuthViewModel())
}
