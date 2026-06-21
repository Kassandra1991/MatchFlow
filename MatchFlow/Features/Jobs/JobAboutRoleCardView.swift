//
//  JobAboutRoleCardView.swift
//  MatchFlow
//

import SwiftUI

struct JobAboutRoleCardView: View {
    let summary: String
    let skills: [String]
    let url: String?

    private var displayedSkills: [String] {
        Array(skills.prefix(Job.maxAnalysisSkills))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s16) {
            Text("About the role")
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .padding(.leading, DSSpacing.s16)

            VStack(alignment: .leading, spacing: DSSpacing.s16) {
                Text(summary)
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !displayedSkills.isEmpty {
                    FlowLayout(items: displayedSkills) { skill in
                        SkillTag(name: skill, style: .primary)
                    }
                }

                if let linkLabel = urlLinkLabel, let linkURL = url.flatMap(URL.init(string:)) {
                    Rectangle()
                        .fill(Color.borderDefault)
                        .frame(height: DSStroke.s1)
                        .padding(.horizontal, DSSpacing.s8)

                    HStack {
                        Text("URL")
                            .textStyle(.body1Regular)
                            .foregroundStyle(Color.foregroundPrimary)
                        Spacer()
                        Link(linkLabel, destination: linkURL)
                            .textStyle(.body1Regular)
                            .foregroundStyle(Color.foregroundAccent)
                    }
                }
            }
            .padding(DSSpacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .jobDetailCard()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var urlLinkLabel: String? {
        guard let url, let host = URL(string: url)?.host?.lowercased() else { return nil }
        if host.contains("linkedin") { return "LinkedIn" }
        return host
    }
}
