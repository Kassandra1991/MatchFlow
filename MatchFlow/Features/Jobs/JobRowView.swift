//
//  JobRowView.swift
//  MatchFlow
//

import SwiftUI

struct JobRowView: View {
    let job: Job
    var style: JobRowViewStyle = .list

    private var titleParts: (primary: String, secondary: String?) {
        JobStatusStyle.titleParts(for: job.title)
    }

    var body: some View {
        if style == .list {
            listRow
        } else {
            insightsCardRow
        }
    }

    private var listRow: some View {
        HStack(alignment: .top, spacing: DSSpacing.s16) {
            CompanyLogoView(logoUrl: job.companyLogoUrl, style: .list)

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                HStack(alignment: .top, spacing: DSSpacing.s8) {
                    Text(job.company ?? "Unknown Company")
                        .textStyle(.body1Semibold)
                        .foregroundStyle(Color.foregroundPrimary)
                        .lineLimit(1)

                    Spacer(minLength: DSSpacing.s8)

                    trailingActions
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

    private var insightsCardRow: some View {
        HStack(alignment: .top, spacing: DSSpacing.s16) {
            CompanyLogoView(logoUrl: job.companyLogoUrl, style: .list)

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                Text(job.company ?? "Unknown Company")
                    .textStyle(.body1Semibold)
                    .foregroundStyle(Color.foregroundPrimary)
                    .lineLimit(1)

                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.s4) {
                        Text(insightsRoleLine)
                            .textStyle(.captionRegular)
                            .foregroundStyle(Color.foregroundSecondary)
                            .lineLimit(2)

                        insightsStatusLabel
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: DSSpacing.s16)

                    trailingActions
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var trailingActions: some View {
        HStack(spacing: DSSpacing.s8) {
            if let score = job.matchScore {
                MatchPercentCapsule(
                    percent: Int(score * 100),
                    tier: MatchScoreTier(score: score)
                )
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(style == .insightsCard ? Color.foregroundMinor : Color.foregroundSecondary)
                .frame(width: 14, height: 20, alignment: .center)
        }
    }

    private var insightsRoleLine: String {
        if let secondary = titleParts.secondary, !secondary.isEmpty {
            return "\(titleParts.primary) / \(secondary)"
        }
        return titleParts.primary
    }

    private var insightsStatusText: String {
        "• \(JobStatusStyle.listLabel(for: job.status))"
    }

    private var insightsStatusLabel: some View {
        ViewThatFits(in: .horizontal) {
            Text(insightsStatusText)
                .textStyle(.captionRegular)
                .foregroundStyle(Color.foregroundSecondary)
                .lineLimit(1)

            Text(insightsStatusText)
                .textStyle(.captionRegular)
                .foregroundStyle(Color.foregroundSecondary)
                .lineLimit(2)
        }
    }
}

enum JobRowViewStyle {
    case list
    case insightsCard
}
