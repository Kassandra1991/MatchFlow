//
//  AddJobImportLayout.swift
//  MatchFlow
//

import CoreGraphics
import Foundation

enum AddJobImportLayout {
    static let topOffset = DSSpacing.s102
    static let illustrationToHeader = DSSpacing.s8
    static let headerToBody = DSSpacing.s16
    static let bodyToInput = DSSpacing.s32
    static let inputToFooter: CGFloat = 33
    static let contentHorizontalInset = DSSpacing.s16
    static let inputRowHeight: CGFloat = 52
    static let pasteButtonHeight: CGFloat = 38
    /// Centers the 38pt paste button inside the 52pt input row.
    static let pasteButtonInset: CGFloat = (inputRowHeight - pasteButtonHeight) / 2
    static let inputTextLeadingInset = DSSpacing.s24
    static let pasteButtonHorizontalPadding = DSSpacing.s16

    static func isValidJobURL(_ string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("http"), URL(string: trimmed) != nil else { return false }
        return true
    }
}
