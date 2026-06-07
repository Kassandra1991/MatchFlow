//
//  SplashBackgroundView.swift
//  MatchFlow
//

import SwiftUI

struct SplashBackgroundView: View {
    var body: some View {
        Image("SplashBackground")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
