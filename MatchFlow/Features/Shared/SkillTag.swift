//
//  SkillTag.swift
//  MatchFlow
//

import SwiftUI

struct SkillTag: View {
    let name: String

    var body: some View {
        Text(name)
            .textStyle(.captionRegular)
            .padding(.horizontal, DSSpacing.s8 + DSSpacing.s2)
            .padding(.vertical, DSSpacing.s4)
            .background(Color.backgroundAccent)
            .foregroundStyle(Color.foregroundAccent)
            .clipShape(Capsule())
    }
}
