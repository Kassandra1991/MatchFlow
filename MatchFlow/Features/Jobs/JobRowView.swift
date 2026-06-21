//
//  JobRowView.swift
//  MatchFlow
//

import SwiftUI

struct JobRowView: View {
    let job: Job

    private var titleParts: (primary: String, secondary: String?) {
        JobStatusStyle.titleParts(for: job.title)
    }

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.s16) {
            CompanyLogoView(logoUrl: job.companyLogoUrl, style: .list)

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                HStack(alignment: .top, spacing: DSSpacing.s8) {
                    Text(job.company ?? "Unknown Company")
                        .textStyle(.body1Semibold)
                        .foregroundStyle(Color.foregroundPrimary)
                        .lineLimit(1)

                    Spacer(minLength: DSSpacing.s8)

                    if let score = job.matchScore {
                        MatchPercentCapsule(
                            percent: Int(score * 100),
                            tier: MatchScoreTier(score: score)
                        )
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.foregroundSecondary)
                        .frame(width: 14, height: 20, alignment: .center)
                }

                Text(titleParts.primary)
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundSecondary)
                    .lineLimit(2)

                Text(JobStatusStyle.listSubtitle(secondaryTitle: titleParts.secondary, status: job.status))
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DSSpacing.s8)
    }
}
