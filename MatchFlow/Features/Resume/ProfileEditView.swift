//
//  ProfileEditView.swift
//  MatchFlow
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss

    @State private var initialSnapshot: ProfileEditSnapshot?

    private let workStyleOptions = ["Hybrid", "Remote"]

    private var isSaveEnabled: Bool {
        hasChanges
            && !viewModel.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.isSaving
            && userId != nil
    }

    private var hasChanges: Bool {
        guard let initialSnapshot else { return false }
        return currentSnapshot != initialSnapshot
    }

    var body: some View {
        VStack(spacing: DSSpacing.s0) {
            editHeader
                .padding(.horizontal, DSSpacing.s16)
                .padding(.top, DSSpacing.s16)
                .padding(.bottom, DSSpacing.s8)

            ScrollView {
                VStack(spacing: DSSpacing.s16) {
                    profileFieldsCard
                    companyCard
                    footerCaption

                    if !viewModel.errorMessage.isEmpty {
                        AuthErrorBanner(message: viewModel.errorMessage)
                    }

                    // Future feature: career goals editor
                    // VStack(alignment: .leading, spacing: DSSpacing.s8) {
                    //     Text("Career goals")
                    //         .textStyle(.captionRegular)
                    //         .foregroundStyle(Color.foregroundSecondary)
                    //     TextEditor(text: $viewModel.careerGoals)
                    //         .textStyle(.body1Regular)
                    //         .frame(minHeight: 100)
                    //         .padding(DSSpacing.s8)
                    //         .background(Color.backgroundSecondary)
                    //         .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
                    // }
                }
                .padding(DSSpacing.s16)
            }
        }
        .background(Color.backgroundPrimary)
        .onAppear {
            initialSnapshot = currentSnapshot
        }
    }

    private var editHeader: some View {
        ZStack {
            Text("Edit profile")
                .textStyle(.body1Semibold)
                .foregroundStyle(Color.foregroundPrimary)

            HStack {
                Button {
                    viewModel.isEditing = false
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.foregroundPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color.backgroundSecondary, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                DSButton(
                    title: "Save",
                    size: .medium,
                    width: .hug,
                    isEnabled: isSaveEnabled,
                    isLoading: viewModel.isSaving
                ) {
                    Task {
                        if let userId {
                            await viewModel.saveProfile(userId: userId)
                            if viewModel.errorMessage.isEmpty {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }

    private var profileFieldsCard: some View {
        VStack(spacing: DSSpacing.s0) {
            profileTextRow(label: "Full name", text: $viewModel.fullName)

            fieldDivider

            profileTextRow(label: "Job title", text: $viewModel.headline)

            fieldDivider

            workStyleRow
        }
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
    }

    private func profileTextRow(label: String, text: Binding<String>) -> some View {
        HStack(spacing: DSSpacing.s16) {
            Text(label)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)

            TextField("", text: text)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundSecondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, DSSpacing.s16)
        .padding(.vertical, DSSpacing.s16)
    }

    private var workStyleRow: some View {
        HStack(spacing: DSSpacing.s16) {
            Text("Work style")
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)

            Spacer()

            Menu {
                ForEach(workStyleOptions, id: \.self) { option in
                    Button(option) {
                        viewModel.workStyle = option
                    }
                }
            } label: {
                HStack(spacing: DSSpacing.s4) {
                    Text(viewModel.workStyle.isEmpty ? workStyleOptions[0] : viewModel.workStyle)
                        .textStyle(.body1Regular)
                        .foregroundStyle(Color.foregroundSecondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.foregroundSecondary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.s16)
        .padding(.vertical, DSSpacing.s16)
    }

    private var companyCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s0) {
            Text("What matters to me in a company")
                .textStyle(.body1Semibold)
                .foregroundStyle(Color.foregroundPrimary)
                .padding(.horizontal, DSSpacing.s16)
                .padding(.vertical, DSSpacing.s16)

            fieldDivider

            TextEditor(text: $viewModel.importantInCompany)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundSecondary)
                .frame(minHeight: 100)
                .padding(.horizontal, DSSpacing.s16)
                .padding(.vertical, DSSpacing.s8)
                .scrollContentBackground(.hidden)
        }
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
    }

    private var footerCaption: some View {
        Text("This is used as additional matching criteria and to generate your cover letters.")
            .textStyle(.captionRegular)
            .foregroundStyle(Color.foregroundSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.s16)
    }

    private var fieldDivider: some View {
        Rectangle()
            .fill(Color.borderDefault)
            .frame(height: DSStroke.s1)
    }

    private var currentSnapshot: ProfileEditSnapshot {
        ProfileEditSnapshot(
            fullName: viewModel.fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            headline: viewModel.headline.trimmingCharacters(in: .whitespacesAndNewlines),
            importantInCompany: viewModel.importantInCompany.trimmingCharacters(in: .whitespacesAndNewlines),
            workStyle: viewModel.workStyle.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

private struct ProfileEditSnapshot: Equatable {
    let fullName: String
    let headline: String
    let importantInCompany: String
    let workStyle: String
}
