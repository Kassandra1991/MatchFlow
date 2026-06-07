//
//  SplashLogoView.swift
//  MatchFlow
//

import SwiftUI

struct SplashLogoView: View {
    var body: some View {
        Image("SplashLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 200)
    }
}

#Preview {
    ZStack {
        SplashBackgroundView()
        SplashLogoView()
    }
}
