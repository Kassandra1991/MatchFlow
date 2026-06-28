//
//  AddJobImportView.swift
//  MatchFlow
//

import SwiftUI

struct AddJobImportView: View {
    @ObservedObject var viewModel: JobsViewModel
    let userId: UUID?
    let onImportSuccess: () -> Void
    let onManualAdd: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var jobLink = ""
    @FocusState private var isLinkFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.s0) {
                Image("AddJobShareIllustration")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280)
                    .padding(.top, AddJobImportLayout.topOffset)

                Text("Share a job directly to JobMatch from LinkedIn or any app")
                    .textStyle(.header1)
                    .foregroundStyle(Color.foregroundPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AddJobImportLayout.illustrationToHeader)

                Text("Paste a link and we'll automatically extract the job details for you")
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AddJobImportLayout.headerToBody)

                linkInputRow
                    .padding(.top, AddJobImportLayout.bodyToInput)

                if !viewModel.errorMessage.isEmpty {
                    AuthErrorBanner(message: viewModel.errorMessage)
                        .padding(.top, DSSpacing.s16)
                }

                footerLink
                    .padding(.top, AddJobImportLayout.inputToFooter)
            }
            .padding(.bottom, DSSpacing.s32)
        }
        .contentMargins(.horizontal, AddJobImportLayout.contentHorizontalInset, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .overlay(alignment: .topLeading) {
            closeButton
                .padding(.horizontal, DSSpacing.s16)
                .padding(.top, DSSpacing.s16)
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.foregroundPrimary)
                .frame(width: 44, height: 44)
                .background(Color.backgroundSecondary, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var linkInputRow: some View {
        HStack(spacing: DSSpacing.s0) {
            ZStack(alignment: .leading) {
                TextField("", text: $jobLink)
                    .focused($isLinkFocused)
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundPrimary)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.leading, AddJobImportLayout.inputTextLeadingInset)

                if jobLink.isEmpty && !isLinkFocused {
                    Text("Paste job link")
                        .textStyle(.body1Regular)
                        .foregroundStyle(Color.foregroundMinor)
                        .padding(.leading, AddJobImportLayout.inputTextLeadingInset)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            pasteButton
                .padding(.trailing, AddJobImportLayout.pasteButtonInset)
        }
        .frame(height: AddJobImportLayout.inputRowHeight)
        .background(Color.backgroundSecondary, in: Capsule())
    }

    private var pasteButton: some View {
        Button {
            pasteFromClipboard()
        } label: {
            HStack(spacing: DSSpacing.s8) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color.foregroundPrimaryWhite)
                } else {
                    Image(systemName: "doc.on.clipboard")
                        .font(DSTextStyle.body2Semibold.font)
                }
                Text("Paste")
                    .textStyle(.body2Semibold)
            }
            .foregroundStyle(Color.foregroundPrimaryWhite)
            .padding(.horizontal, AddJobImportLayout.pasteButtonHorizontalPadding)
            .frame(height: AddJobImportLayout.pasteButtonHeight)
            .background(Color.buttonPrimary, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(userId == nil || viewModel.isLoading)
    }

    private var footerLink: some View {
        Button(action: onManualAdd) {
            HStack(spacing: DSSpacing.s0) {
                Text("Can't import the job? ")
                    .textStyle(.body2Regular)
                    .foregroundStyle(Color.foregroundSecondary)
                Text("Add manually")
                    .textStyle(.body2Semibold)
                    .foregroundStyle(Color.foregroundAccent)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func pasteFromClipboard() {
        guard let clipboard = UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !clipboard.isEmpty
        else {
            viewModel.errorMessage = "No link in clipboard"
            return
        }

        guard AddJobImportLayout.isValidJobURL(clipboard) else {
            viewModel.errorMessage = "Paste a valid job link"
            return
        }

        jobLink = clipboard
        guard let userId else { return }

        Task {
            let success = await viewModel.addJobFromPastedURL(userId: userId, url: clipboard)
            if success {
                onImportSuccess()
            }
        }
    }
}
