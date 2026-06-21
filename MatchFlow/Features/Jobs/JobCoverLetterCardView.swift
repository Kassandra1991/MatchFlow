//
//  JobCoverLetterCardView.swift
//  MatchFlow
//

import SwiftUI

struct JobCoverLetterCardView: View {
    let isGenerating: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s8) {
            Button(action: action) {
                HStack(alignment: .center, spacing: DSSpacing.s16) {
                    Image(systemName: "mail.fill")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.foregroundPrimary)

                    Text("Generate cover letter")
                        .textStyle(.body1Regular)
                        .foregroundStyle(Color.foregroundPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isGenerating {
                        ProgressView()
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.foregroundSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled || isGenerating)

            Text("Create a role-specific cover letter using insights from your CV and job match analysis.")
                .textStyle(.captionRegular)
                .foregroundStyle(Color.foregroundSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(DSSpacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r24))
    }
}

#Preview {
    JobCoverLetterCardView(isGenerating: false, isEnabled: true, action: { })
}
