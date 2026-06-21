//
//  InsightsHeroView.swift
//  MatchFlow
//

import SwiftUI

struct InsightsHeroView: View {
    let isOnboarding: Bool
    let adviceText: String?
    let isLoadingAdvice: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            InsightsHeroBackground()
                .frame(height: heroHeight)

            VStack(spacing: DSSpacing.s16) {
                Text(isOnboarding ? "✨" : "😎")
                    .font(.system(size: 48))

                if isOnboarding {
                    onboardingContent
                } else {
                    activeContent
                }
            }
            .padding(.horizontal, DSSpacing.s16)
            .padding(.top, InsightsHeroLayout.emojiTopFromScreen)
            .padding(.bottom, InsightsHeroLayout.addJobCardOverlap + DSSpacing.s24)
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight, alignment: .top)
        }
    }

    private var heroHeight: CGFloat {
        if isOnboarding {
            return InsightsHeroLayout.emojiTopFromScreen
                + 48
                + DSSpacing.s16
                + InsightsHeroLayout.onboardingTitleHeight
                + DSSpacing.s16
                + InsightsHeroLayout.onboardingBodyHeight
                + InsightsHeroLayout.onboardingBodyToAddJobSpacing
                + InsightsHeroLayout.addJobCardOverlap
        }
        return InsightsHeroLayout.emojiTopFromScreen
            + 48
            + DSSpacing.s16
            + InsightsHeroLayout.keepGoingTitleHeight
            + DSSpacing.s16
            + InsightsHeroLayout.adviceTextHeight
            + InsightsHeroLayout.adviceToAddJobSpacing
            + InsightsHeroLayout.addJobCardOverlap
    }

    private var onboardingContent: some View {
        VStack(spacing: DSSpacing.s16) {
            Text("Find gaps. Improve your CV.\nGet hired")
                .textStyle(.title2)
                .foregroundStyle(Color.foregroundPrimaryWhite)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)

            Text("Start by adding jobs you're interested in. The app will analyse them against your CV to build your personalised job match profile.")
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundSecondaryWhite)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var activeContent: some View {
        VStack(spacing: DSSpacing.s16) {
            Text("Keep going!")
                .textStyle(.title2)
                .foregroundStyle(Color.foregroundPrimaryWhite)
                .multilineTextAlignment(.center)

            adviceTextSlot
        }
    }

    private var adviceTextSlot: some View {
        Group {
            if isLoadingAdvice {
                analyzingLabel
            } else if let adviceText, !adviceText.isEmpty {
                Text(InsightsHeroLayout.clampedAdvice(adviceText))
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundSecondaryWhite)
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
            } else {
                analyzingLabel
            }
        }
        .frame(
            minHeight: InsightsHeroLayout.adviceTextHeight,
            maxHeight: InsightsHeroLayout.adviceTextHeight,
            alignment: .top
        )
        .frame(maxWidth: .infinity)
    }

    private var analyzingLabel: some View {
        HStack(spacing: DSSpacing.s8) {
            ProgressView()
                .tint(Color.foregroundSecondaryWhite)
            Text("Analyzing…")
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundSecondaryWhite)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
