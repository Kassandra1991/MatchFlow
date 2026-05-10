//
//  ResumeView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import Auth
import Supabase
import PDFKit

struct ResumeView: View {
    @StateObject private var viewModel = ResumeViewModel()
    @State private var showAddResume = false
    @State private var userId: UUID?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.resumes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No resumes yet")
                            .font(.headline)
                        Text("Upload your resume to get AI match scores")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Upload Resume") {
                            showAddResume = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.resumes) { resume in
                            ResumeRowView(resume: resume) {
                                if let userId {
                                    Task { await viewModel.setDefault(resume: resume, userId: userId) }
                                }
                            } onDelete: {
                                Task { await viewModel.deleteResume(resume: resume) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Resumes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddResume = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddResume) {
                AddResumeView(viewModel: viewModel, userId: userId)
            }
            .task {
                if let session = try? await supabase.auth.session,
                   let uuid = UUID(uuidString: session.user.id.uuidString) {
                    userId = uuid
                    await viewModel.fetchResumes(userId: uuid)
                }
            }
        }
    }
}

struct ResumeRowView: View {
    let resume: Resume
    let onSetDefault: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(resume.title)
                        .font(.headline)
                    if resume.isDefault {
                        Text("Default")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
                Text(resume.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Menu {
                if !resume.isDefault {
                    Button("Set as Default", action: onSetDefault)
                }
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddResumeView: View {
    @ObservedObject var viewModel: ResumeViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var rawText = ""
    @State private var isDefault = true
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
                
                Section {
                    Toggle("Set as Default", isOn: $isDefault)
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
                                    isDefault: isDefault
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(rawText.isEmpty || viewModel.isLoading)
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.pdf],
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
