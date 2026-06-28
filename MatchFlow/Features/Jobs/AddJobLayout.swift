//
//  AddJobLayout.swift
//  MatchFlow
//

import CoreGraphics
import Foundation
import SwiftUI

enum AddJobLayout {
    /// Title offset below toolbar row (back + Add).
    static let titleTopFromToolbar = DSSpacing.s32
    static let titleToSubtitle = DSSpacing.s16
    static let subtitleToFieldsCard = DSSpacing.s32
    static let cardSpacing = DSSpacing.s16
    static let rowHorizontalInset = DSSpacing.s16
    static let descriptionInset = DSSpacing.s24
    static let descriptionMinHeight: CGFloat = 200
    /// Cancels UITextView default content inset so typed text aligns with the placeholder.
    static let textEditorInsetCompensation = EdgeInsets(
        top: -8,
        leading: -5,
        bottom: -8,
        trailing: -5
    )
    /// Minimum trimmed description length (~4 short sentences).
    static let minDescriptionCharacterCount = 300

    static func isDescriptionSufficient(_ text: String) -> Bool {
        trimmedCharacterCount(text) >= minDescriptionCharacterCount
    }

    static func trimmedCharacterCount(_ text: String) -> Int {
        text.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    static func charactersRemaining(_ text: String) -> Int {
        max(0, minDescriptionCharacterCount - trimmedCharacterCount(text))
    }

    static func charactersRemainingMessage(_ text: String) -> String? {
        guard trimmedCharacterCount(text) > 0 else { return nil }
        let remaining = charactersRemaining(text)
        guard remaining > 0 else { return nil }
        if remaining == 1 {
            return "Need 1 more character"
        }
        return "Need \(remaining) more characters"
    }
}
