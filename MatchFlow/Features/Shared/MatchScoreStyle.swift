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
            return .foregroundMatchLow
        case .medium:
            return .foregroundMatchMedium
        case .high, .excellent:
            return .foregroundMatchHigh
        }
    }

    var backgroundColor: Color {
        switch self {
        case .low:
            return .backgroundMatchLow
        case .medium:
            return .backgroundMatchMedium
        case .high, .excellent:
            return .backgroundMatchHigh
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

    func rowLabel(percent: Int) -> String {
        if self == .excellent {
            return "Excellent match · \(percent)%"
        }
        return "Match: \(percent)%"
    }

    func listPercentLabel(percent: Int) -> String {
        "\(percent)%"
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
