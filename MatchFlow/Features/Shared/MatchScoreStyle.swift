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

    func listPercentLabel(percent: Int) -> String {
        "\(percent)%"
    }

    var detailTitle: String {
        switch self {
        case .low:
            return "Low match"
        case .medium:
            return "Moderate match"
        case .high:
            return "Strong match"
        case .excellent:
            return "Excellent match"
        }
    }
}
