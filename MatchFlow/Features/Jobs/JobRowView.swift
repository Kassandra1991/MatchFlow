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
            companyLogo

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                HStack(alignment: .top, spacing: DSSpacing.s8) {
                    Text(job.company ?? "Unknown Company")
                        .textStyle(.body1Semibold)
                        .foregroundStyle(Color.foregroundPrimary)
                        .lineLimit(1)

                    Spacer(minLength: DSSpacing.s8)

                    if let score = job.matchScore {
                        compactMatchBadge(score: score)
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

    @ViewBuilder
    private var companyLogo: some View {
        Group {
            if let logoUrl = job.companyLogoUrl, let url = URL(string: logoUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    logoPlaceholder
                }
            } else {
                logoPlaceholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var logoPlaceholder: some View {
        Circle()
            .fill(Color.backgroundMinor)
            .overlay {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.foregroundSecondary)
            }
    }

    private func compactMatchBadge(score: Double) -> some View {
        let tier = MatchScoreTier(score: score)
        let percent = Int(score * 100)
        return Text(tier.listPercentLabel(percent: percent))
            .textStyle(.captionSemibold)
            .foregroundStyle(tier.foregroundColor)
            .padding(.horizontal, DSSpacing.s8)
            .padding(.vertical, DSSpacing.s4)
            .background(tier.backgroundColor)
            .clipShape(Capsule())
    }
}
