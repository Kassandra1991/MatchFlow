//
//  ProfileEditView.swift
//  MatchFlow
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.s16) {
                    TextField("Full name", text: $viewModel.fullName)
                        .textStyle(.body1Regular)
                        .padding(DSSpacing.s16)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))

                    TextField("Headline (e.g. AI Engineer)", text: $viewModel.headline)
                        .textStyle(.body1Regular)
                        .padding(DSSpacing.s16)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))

                    VStack(alignment: .leading, spacing: DSSpacing.s8) {
                        Text("What's important to you in a company?")
                            .textStyle(.captionRegular)
                            .foregroundStyle(Color.foregroundSecondary)
                        TextEditor(text: $viewModel.importantInCompany)
                            .textStyle(.body1Regular)
                            .frame(minHeight: 100)
                            .padding(DSSpacing.s8)
                            .background(Color.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
                    }

                    TextField("Work style (e.g. Hybrid, Remote)", text: $viewModel.workStyle)
                        .textStyle(.body1Regular)
                        .padding(DSSpacing.s16)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))

                    VStack(alignment: .leading, spacing: DSSpacing.s8) {
                        Text("Career goals")
                            .textStyle(.captionRegular)
                            .foregroundStyle(Color.foregroundSecondary)
                        TextEditor(text: $viewModel.careerGoals)
                            .textStyle(.body1Regular)
                            .frame(minHeight: 100)
                            .padding(DSSpacing.s8)
                            .background(Color.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
                    }

                    if !viewModel.errorMessage.isEmpty {
                        AuthErrorBanner(message: viewModel.errorMessage)
                    }
                }
                .padding(DSSpacing.s16)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isEditing = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            if let userId {
                                await viewModel.saveProfile(userId: userId)
                                if viewModel.errorMessage.isEmpty {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .textStyle(.body1Semibold)
                        }
                    }
                    .disabled(viewModel.fullName.isEmpty || viewModel.isSaving || userId == nil)
                }
            }
        }
    }
}
