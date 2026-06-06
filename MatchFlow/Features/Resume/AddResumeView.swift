//
//  AddResumeView.swift
//  MatchFlow
//

import SwiftUI
import UniformTypeIdentifiers

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
                                    title: title,
                                    rawText: rawText,
                                    isDefault: true
                                )
                                if viewModel.errorMessage.isEmpty {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .disabled(rawText.isEmpty || title.isEmpty || viewModel.isLoading || userId == nil)
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                if let url = try? result.get().first {
                    rawText = viewModel.extractTextFromPDF(url: url)
                }
            }
        }
    }
}
