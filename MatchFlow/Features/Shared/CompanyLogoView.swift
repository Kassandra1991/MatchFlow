//
//  CompanyLogoView.swift
//  MatchFlow
//

import SwiftUI

struct CompanyLogoView: View {
    enum Style {
        case list
        case detail
    }

    let logoUrl: String?
    var style: Style = .list

    private var displayURL: URL? {
        CompanyLogoURL.normalizedDisplayURL(from: logoUrl)
    }

    private var diameter: CGFloat {
        style == .detail ? 88 : 44
    }

    private var iconSize: CGFloat {
        style == .detail ? 32 : 18
    }

    var body: some View {
        Group {
            if let displayURL {
                AsyncImage(url: displayURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholderCircle
                    @unknown default:
                        placeholderCircle
                    }
                }
            } else {
                placeholderCircle
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
    }

    private var placeholderCircle: some View {
        ZStack {
            Circle()
                .fill(Color.backgroundMinor)
            placeholderIcon
        }
    }

    private var placeholderIcon: some View {
        Image(systemName: "briefcase.fill")
            .font(.system(size: iconSize))
            .foregroundStyle(Color.foregroundSecondary)
    }
}
