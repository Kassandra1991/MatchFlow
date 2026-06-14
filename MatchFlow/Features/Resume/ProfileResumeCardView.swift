//
//  ProfileResumeCardView.swift
//  MatchFlow
//

import SwiftUI

struct ProfileResumeCardView: View {
    let resume: Resume
    let onDelete: () -> Void

    var body: some View {
        ProfileChevronCardRow(
            thumbnail: {
                ResumeThumbnailView(
                    systemImage: "doc.text.image",
                    iconColor: Color.foregroundSecondary
                )
            },
            title: resume.title,
            subtitle: "Uploaded \(resume.createdAt.formatted(date: .abbreviated, time: .omitted))"
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ProfileResumeEmptyCardView: View {
    let onUpload: () -> Void

    var body: some View {
        Button(action: onUpload) {
            ProfileChevronCardRow(
                thumbnail: {
                    ResumeThumbnailView(
                        systemImage: "doc.badge.plus",
                        iconColor: Color.foregroundAccent
                    )
                },
                title: "Upload Resume",
                subtitle: "Add your CV as PDF"
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: DSSpacing.s16) {
        ProfileResumeCardView(
            resume: Resume(
                id: UUID(),
                userId: UUID(),
                title: "AI Engineer",
                rawText: nil,
                skillsRaw: nil,
                yearsExperience: nil,
                seniority: nil,
                isDefault: true,
                createdAt: Date()
            ),
            onDelete: {}
        )
        ProfileResumeEmptyCardView(onUpload: {})
    }
    .padding()
}
