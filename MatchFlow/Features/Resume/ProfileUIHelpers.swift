//
//  ProfileUIHelpers.swift
//  MatchFlow
//

import SwiftUI

enum ProfileLayout {
    static let headerTop = DSSpacing.s116
    /// Menu top offset from physical top (Figma).
    static let menuTop = DSSpacing.s62
}

struct ResumeThumbnailView: View {
    let systemImage: String
    let iconColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSRadius.r16)
                .fill(Color.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.r16)
                        .stroke(Color.borderDefault, lineWidth: DSStroke.s1)
                )
                .frame(width: 48, height: 64)
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
        }
    }
}

struct ProfileChevronCardRow<Thumbnail: View>: View {
    @ViewBuilder let thumbnail: () -> Thumbnail
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: DSSpacing.s16) {
            thumbnail()

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                Text(title)
                    .textStyle(.body1Semibold)
                    .foregroundStyle(Color.foregroundPrimary)
                Text(subtitle)
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.foregroundSecondary)
        }
        .padding(DSSpacing.s16)
        .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r16))
    }
}

struct ProfileCardDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.borderDefault)
            .frame(height: DSStroke.s1)
    }
}

extension View {
    func profileSecondaryCard() -> some View {
        background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
    }
}
