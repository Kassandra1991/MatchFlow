//
//  AuthBackButton.swift
//  MatchFlow
//

import SwiftUI

struct AuthBackButton: View {
    var action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.foregroundPrimary)
                    .frame(minWidth: 44, minHeight: 44, alignment: .leading)
            }
            Spacer()
        }
    }
}

#Preview {
    AuthBackButton(action: {})
        .padding(.horizontal, DSSpacing.s16)
}
