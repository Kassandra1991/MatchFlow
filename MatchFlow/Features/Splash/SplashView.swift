//
//  SplashView.swift
//  MatchFlow
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            SplashBackgroundView()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
    }
}

#Preview {
    SplashView()
}
