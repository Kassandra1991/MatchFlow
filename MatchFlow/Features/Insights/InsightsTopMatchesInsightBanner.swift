//
//  InsightsTopMatchesInsightBanner.swift
//  MatchFlow
//

import SwiftUI

enum InsightsTopMatchesInsightLayout {
    /// Minimum AI insight banner height (Figma, ~3 lines).
    static let bannerMinHeight: CGFloat = 91
    /// Approximate body2Regular line height for 4-line expansion.
    static let textLineHeight: CGFloat = 20
    /// Max visible lines when insight is long.
    static let maxLines = 4
    /// Reference vertical inset when icon is centered in 91pt block (Figma).
    static let bannerVerticalPadding: CGFloat = 28.5
    /// Leading inset for sparkles icon (Figma).
    static let bannerLeadingPadding: CGFloat = 24
    /// Spacing between sparkles and text (Figma).
    static let iconToTextSpacing: CGFloat = 24
    /// Trailing inset for text (Figma).
    static let bannerTrailingPadding: CGFloat = 16
    static var bannerMaxHeight: CGFloat {
        bannerMinHeight + textLineHeight
    }

    /// Max characters for insight (fits up to 4 lines body2Regular in banner).
    static let maxCharacters = 130

    static func clampedInsight(_ text: String) -> String {
        guard text.count > maxCharacters else { return text }
        return String(text.prefix(maxCharacters - 1)) + "…"
    }
}

struct InsightsTopMatchesInsightBanner: View {
    let insight: String?
    let isLoading: Bool

    var body: some View {
        if isLoading {
            bannerContent {
                HStack(spacing: DSSpacing.s8) {
                    ProgressView()
                    Text("Analyzing your top matches…")
                        .textStyle(.body2Regular)
                        .foregroundStyle(Color.foregroundPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else if let insight, !insight.isEmpty {
            bannerContent {
                insightText(insight)
            }
        }
    }

    private func insightText(_ insight: String) -> some View {
        Text(InsightsTopMatchesInsightLayout.clampedInsight(insight))
            .textStyle(.body2Regular)
            .foregroundStyle(Color.foregroundPrimary)
            .multilineTextAlignment(.leading)
            .lineLimit(InsightsTopMatchesInsightLayout.maxLines)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func bannerContent<Content: View>(@ViewBuilder text: () -> Content) -> some View {
        HStack(alignment: .center, spacing: InsightsTopMatchesInsightLayout.iconToTextSpacing) {
            Image(systemName: "sparkles")
                .font(DSTextStyle.header1.font)
                .foregroundStyle(Color.foregroundAccent)

            text()
        }
        .padding(.leading, InsightsTopMatchesInsightLayout.bannerLeadingPadding)
        .padding(.trailing, InsightsTopMatchesInsightLayout.bannerTrailingPadding)
        .frame(maxWidth: .infinity, minHeight: InsightsTopMatchesInsightLayout.bannerMinHeight, alignment: .center)
        .background(Color.backgroundAccent, in: RoundedRectangle(cornerRadius: DSRadius.r16))
        .padding(DSSpacing.s16)
    }
}
