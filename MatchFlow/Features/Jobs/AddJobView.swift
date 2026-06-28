//
//  AddJobView.swift
//  MatchFlow
//

import SwiftUI

struct AddJobView: View {
    @ObservedObject var viewModel: JobsViewModel
    let userId: UUID?
    let onAddSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var company = ""
    @State private var url = ""
    @State private var rawText = ""
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case company
        case url
        case description
    }

    private var isAddEnabled: Bool {
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && AddJobLayout.isDescriptionSufficient(rawText)
            && userId != nil
            && !viewModel.isLoading
    }

    private var showsDescriptionLengthHint: Bool {
        !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !AddJobLayout.isDescriptionSufficient(rawText)
    }

    var body: some View {
        VStack(spacing: DSSpacing.s0) {
            toolbarRow
                .padding(.horizontal, DSSpacing.s16)
                .padding(.top, DSSpacing.s16)

            ScrollView {
                VStack(spacing: DSSpacing.s0) {
                    Text("Add job details manually")
                        .textStyle(.header1)
                        .foregroundStyle(Color.foregroundPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, AddJobLayout.titleTopFromToolbar)

                    Text("Paste the job description below to extract the details and see how well it matches your CV.")
                        .textStyle(.body1Regular)
                        .foregroundStyle(Color.foregroundSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, AddJobLayout.titleToSubtitle)

                    VStack(spacing: AddJobLayout.cardSpacing) {
                        metadataCard
                        descriptionCard

                        if showsDescriptionLengthHint,
                           let message = AddJobLayout.charactersRemainingMessage(rawText) {
                            Text(message)
                                .textStyle(.captionRegular)
                                .foregroundStyle(Color.foregroundSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, AddJobLayout.subtitleToFieldsCard)

                    if !viewModel.errorMessage.isEmpty {
                        AuthErrorBanner(message: viewModel.errorMessage)
                            .padding(.top, DSSpacing.s16)
                    }
                }
                .padding(.horizontal, DSSpacing.s16)
                .padding(.bottom, DSSpacing.s32)
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }

    private var toolbarRow: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.foregroundPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.backgroundSecondary, in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            DSButton(
                title: "Add",
                size: .medium,
                width: .hug,
                isEnabled: isAddEnabled,
                isLoading: viewModel.isLoading
            ) {
                Task {
                    guard let userId else { return }
                    viewModel.errorMessage = ""
                    await viewModel.addJobManually(
                        userId: userId,
                        url: url,
                        company: company,
                        rawText: rawText
                    )
                    if viewModel.errorMessage.isEmpty {
                        onAddSuccess()
                    }
                }
            }
        }
    }

    private var metadataCard: some View {
        VStack(spacing: DSSpacing.s0) {
            formRow(label: "Company name", text: $company, field: .company)

            ProfileCardDivider()

            formRow(label: "URL (Optional)", text: $url, field: .url, keyboard: .URL)
        }
        .profileSecondaryCard()
    }

    private var descriptionCard: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $rawText)
                .focused($focusedField, equals: .description)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: AddJobLayout.descriptionMinHeight)
                .padding(AddJobLayout.textEditorInsetCompensation)

            if rawText.isEmpty && focusedField != .description {
                Text("Paste job description")
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundMinor)
                    .allowsHitTesting(false)
            }
        }
        .padding(AddJobLayout.descriptionInset)
        .profileSecondaryCard()
    }

    private func formRow(
        label: String,
        text: Binding<String>,
        field: Field,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: DSSpacing.s16) {
            Text(label)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)

            trailingInputField(text: text, field: field, keyboard: keyboard)
        }
        .padding(.leading, AddJobLayout.rowHorizontalInset)
        .padding(.trailing, AddJobLayout.rowHorizontalInset)
        .padding(.vertical, DSSpacing.s16)
    }

    private func trailingInputField(
        text: Binding<String>,
        field: Field,
        keyboard: UIKeyboardType
    ) -> some View {
        ZStack(alignment: .trailing) {
            TextField("", text: text)
                .focused($focusedField, equals: field)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)
                .multilineTextAlignment(.trailing)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .URL ? .never : .sentences)
                .autocorrectionDisabled(keyboard == .URL)

            if text.wrappedValue.isEmpty && focusedField != field {
                Text("Add")
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundMinor)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
