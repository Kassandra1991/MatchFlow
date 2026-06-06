//
//  SkillTag.swift
//  MatchFlow
//

import SwiftUI

struct SkillTag: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
