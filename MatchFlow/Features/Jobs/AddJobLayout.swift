//
//  AddJobLayout.swift
//  MatchFlow
//

import CoreGraphics
import Foundation
import SwiftUI

enum AddJobLayout {
    /// Figma reference — title offset from physical screen top.
    static let titleTopFromScreen: CGFloat = DSSpacing.s102
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
        text.trimmingCharacters(in: .whitespacesAndNewlines).count >= minDescriptionCharacterCount
    }
}
