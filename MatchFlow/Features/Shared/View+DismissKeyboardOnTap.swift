//
//  View+DismissKeyboardOnTap.swift
//  MatchFlow
//

import SwiftUI

extension View {
    func dismissesKeyboardOnTap(focused: FocusState<Bool>.Binding) -> some View {
        contentShape(Rectangle())
            .onTapGesture { focused.wrappedValue = false }
    }
}
