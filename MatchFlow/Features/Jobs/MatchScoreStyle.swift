//
//  MatchScoreStyle.swift
//  MatchFlow
//

import SwiftUI

enum MatchScoreTier: Equatable {
    case low
    case medium
    case high
    case excellent

    init(score: Double) {
        switch score {
        case 0.90...:
            self = .excellent
        case 0.61..<0.90:
            self = .high
        case 0.30..<0.61:
            self = .medium
        default:
            self = .low
        }
    }

    var foregroundColor: Color {
        switch self {
        case .low:
            return Color.black.opacity(0.6)
        case .medium:
            return .orange
        case .high, .excellent:
            return .green
        }
    }

    var backgroundColor: Color {
        switch self {
        case .low:
            return Color.black.opacity(0.1)
        case .medium:
            return Color.orange.opacity(0.15)
        case .high, .excellent:
            return Color.green.opacity(0.15)
        }
    }

    func primaryLabel(percent: Int) -> String {
        switch self {
        case .excellent:
            return "Excellent match"
        default:
            return "\(percent)% Match"
        }
    }

    func secondaryLabel(percent: Int) -> String? {
        self == .excellent ? "\(percent)%" : nil
    }
}

enum MatchScoreStyle {
    static func tier(for score: Double) -> MatchScoreTier {
        MatchScoreTier(score: score)
    }

    static func foregroundColor(for score: Double) -> Color {
        tier(for: score).foregroundColor
    }

    static func backgroundColor(for score: Double) -> Color {
        tier(for: score).backgroundColor
    }
}
