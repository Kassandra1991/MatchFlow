//
//  InsightsHeroLayout.swift
//  MatchFlow
//

import CoreGraphics

enum InsightsHeroLayout {
    /// Emoji offset from physical screen top (Figma, exact).
    static let emojiTopFromScreen: CGFloat = 145.5
    /// Figma reference only — 83.5 from safe area; use `emojiTopFromScreen` in layout.
    static let emojiTopFromSafeArea: CGFloat = 83.5
    /// Fixed AI advice container height (Figma).
    static let adviceTextHeight: CGFloat = 125
    /// Spacing from advice container bottom to Add job card top (Figma).
    static let adviceToAddJobSpacing: CGFloat = 113.5
    /// Max characters for hero advice (fits ~5 lines in 125pt body1Regular).
    static let adviceMaxCharacters = 145
    /// Spacing from onboarding body text to Add job card top (Figma).
    static let onboardingBodyToAddJobSpacing: CGFloat = 118
    /// Title2 block height (up to 3 lines on narrow widths).
    static let onboardingTitleHeight: CGFloat = 120
    /// Onboarding “Start by adding…” body block height estimate.
    static let onboardingBodyHeight: CGFloat = 75
    /// Half of Add job card overlap onto hero gradient.
    static let addJobCardOverlap: CGFloat = 28
    /// InsightsHeroBackground asset aspect ratio (470×1024).
    static let heroBackgroundAspectRatio: CGFloat = 470.0 / 1024.0
    /// Add job plus icon container (squircle).
    static let addJobPlusWidth: CGFloat = 56
    static let addJobPlusHeight: CGFloat = 44
    /// Spacing from Add job card to "Top job matches" header.
    static let addJobToTopMatchesSpacing = DSSpacing.s32
    /// Approximate "Keep going!" title block height for hero sizing.
    static let keepGoingTitleHeight: CGFloat = 34

    static func clampedAdvice(_ text: String) -> String {
        guard text.count > adviceMaxCharacters else { return text }
        return String(text.prefix(adviceMaxCharacters - 1)) + "…"
    }
}
