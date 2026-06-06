//
//  AddJobView.swift
//  MatchFlow
//

import SwiftUI

struct AddJobView: View {
    @ObservedObject var viewModel: JobsViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""
    @State private var rawText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Job URL (optional)") {
                    TextField("https://linkedin.com/jobs/...", text: $url)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                Section("Job Description") {
                    TextEditor(text: $rawText)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            if let userId {
                                await viewModel.addJobManually(
                                    userId: userId,
                                    url: url,
                                    rawText: rawText
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(rawText.isEmpty || viewModel.isLoading || userId == nil)
                }
            }
        }
    }
}
