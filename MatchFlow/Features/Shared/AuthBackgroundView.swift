//
//  AuthBackgroundView.swift
//  MatchFlow
//

import SwiftUI

struct AuthBackgroundView: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            Image("AuthBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}
