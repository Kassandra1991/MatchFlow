//
//  AuthErrorBanner.swift
//  MatchFlow
//

import SwiftUI

struct AuthErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.s8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.foregroundError)

            Text(message)
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DSSpacing.s16)
        .background(Color.backgroundError)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
    }
}

#Preview {
    AuthErrorBanner(message: "Some kind of error: email, password or whatever")
        .padding()
}
