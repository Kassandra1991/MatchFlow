//
//  ProfileHeaderView.swift
//  MatchFlow
//

import SwiftUI

struct ProfileHeaderView: View {
    let profile: UserProfile?

    private static let headerTopOffset = DSSpacing.s116

    var body: some View {
        VStack(spacing: DSSpacing.s0) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 34))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.foregroundPrimaryWhite, Color.foregroundAccent)
                .frame(width: 34, height: 41)

            Text(displayName)
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, DSSpacing.s8)

            if let subtitle = subtitleText, !subtitle.isEmpty {
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
        .padding(.top, Self.headerTopOffset)
    }

    private var displayName: String {
        guard let name = profile?.fullName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return "Add your name"
        }
        return name
    }

    private var subtitleText: String? {
        guard let profile else { return nil }
        let parts = [profile.headline, profile.workStyle]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: " • ")
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
