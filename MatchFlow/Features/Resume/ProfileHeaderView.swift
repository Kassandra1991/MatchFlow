//
//  ProfileHeaderView.swift
//  MatchFlow
//

import SwiftUI

struct ProfileHeaderView: View {
    let profile: UserProfile?

    var body: some View {
        VStack(spacing: DSSpacing.s0) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.foregroundAccent)
                .frame(width: 60, height: 72)

            Text(profile?.displayFullName ?? "Add your name")
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, DSSpacing.s8)

            if let subtitle = profile?.profileSubtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, DSSpacing.s8)
            }

            if let description = profile?.importantInCompany, !description.isEmpty {
                Text(description)
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DSSpacing.s16)
                    .padding(.top, DSSpacing.s24)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileLayout.headerTop)
    }
}

#Preview {
    ZStack {
        AuthBackgroundView()
        ProfileHeaderView(profile: UserProfile(
            id: UUID(),
            email: "test@example.com",
            fullName: "Aliaksandra Asichka",
            headline: "AI Engineer",
            importantInCompany: "I care about a transparent, supportive culture.",
            workStyle: "Hybrid",
            careerGoals: nil,
            coverLetterTone: "friendly"
        ))
    }
    .ignoresSafeArea(edges: .top)
}
