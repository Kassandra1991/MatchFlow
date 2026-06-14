//
//  ProfileResumeCardView.swift
//  MatchFlow
//

import SwiftUI

struct ProfileResumeCardView: View {
    let resume: Resume
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.s16) {
            thumbnail(systemImage: "doc.text.image", iconColor: Color.foregroundSecondary)

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                Text(resume.title)
                    .textStyle(.body1Semibold)
                    .foregroundStyle(Color.foregroundPrimary)
                Text("Uploaded \(resume.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.foregroundSecondary)
        }
        .padding(DSSpacing.s16)
        .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r16))
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func thumbnail(systemImage: String, iconColor: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSRadius.r16)
                .fill(Color.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.r16)
                        .stroke(Color.borderDefault, lineWidth: DSStroke.s1)
                )
                .frame(width: 48, height: 64)
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
        }
    }
}

struct ProfileResumeEmptyCardView: View {
    let onUpload: () -> Void

    var body: some View {
        Button(action: onUpload) {
            HStack(spacing: DSSpacing.s16) {
                thumbnail

                VStack(alignment: .leading, spacing: DSSpacing.s4) {
                    Text("Upload Resume")
                        .textStyle(.body1Semibold)
                        .foregroundStyle(Color.foregroundPrimary)
                    Text("Add your CV as PDF")
                        .textStyle(.captionRegular)
                        .foregroundStyle(Color.foregroundSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.foregroundSecondary)
            }
            .padding(DSSpacing.s16)
            .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r16))
        }
        .buttonStyle(.plain)
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSRadius.r16)
                .fill(Color.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.r16)
                        .stroke(Color.borderDefault, lineWidth: DSStroke.s1)
                )
                .frame(width: 48, height: 64)
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 22))
                .foregroundStyle(Color.foregroundAccent)
        }
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
