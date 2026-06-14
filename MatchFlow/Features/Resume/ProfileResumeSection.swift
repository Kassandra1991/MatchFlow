//
//  ProfileResumeSection.swift
//  MatchFlow
//

import SwiftUI

struct ProfileResumeSection: View {
    let resumes: [Resume]
    let isLoading: Bool
    let onAddResume: () -> Void
    let onOpen: (Resume) -> Void
    let onDelete: (Resume) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s16) {
            headerRow

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.s24)
            } else if resumes.isEmpty {
                ProfileResumeEmptyCardView(onUpload: onAddResume)
            } else {
                ForEach(resumes) { resume in
                    ProfileResumeCardView(resume: resume) {
                        onOpen(resume)
                    } onDelete: {
                        onDelete(resume)
                    }
                }
            }
        }
    }

    private var headerRow: some View {
        HStack {
            Text("My CV")
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)

            Spacer()

            if !resumes.isEmpty {
                updateButton
            }
        }
    }

    private var updateButton: some View {
        Button(action: onAddResume) {
            Text("Update")
                .textStyle(.captionSemibold)
                .foregroundStyle(Color.foregroundPrimary)
                .padding(.horizontal, DSSpacing.s16)
                .padding(.vertical, DSSpacing.s8)
                .background(Color.buttonSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AuthBackgroundView()
        ProfileResumeSection(
            resumes: [],
            isLoading: false,
            onAddResume: {},
            onOpen: { _ in },
            onDelete: { _ in }
        )
        .padding()
    }
}
