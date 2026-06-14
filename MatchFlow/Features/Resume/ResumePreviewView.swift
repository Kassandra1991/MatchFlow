//
//  ResumePreviewView.swift
//  MatchFlow
//

import SwiftUI

struct ResumePreviewView: View {
    let resume: Resume
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    private var content: String {
        resume.rawText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    if content.isEmpty {
                        Text("No resume content available")
                            .textStyle(.captionRegular)
                            .foregroundStyle(Color.foregroundSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(content)
                            .textStyle(.body1Regular)
                            .foregroundStyle(Color.foregroundPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(DSSpacing.s16)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle(resume.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.foregroundSecondary)
                    }
                }
                if !content.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            UIPasteboard.general.string = content
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        } label: {
                            Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ResumePreviewView(
        resume: Resume(
            id: UUID(),
            userId: UUID(),
            title: "AI Engineer",
            rawText: "Senior iOS developer with 5+ years of experience.",
            skillsRaw: nil,
            yearsExperience: nil,
            seniority: nil,
            isDefault: true,
            createdAt: Date()
        )
    )
}
