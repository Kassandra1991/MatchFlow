//
//  NotesEditorView.swift
//  MatchFlow
//

import SwiftUI

struct NotesEditorView: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        TextEditor(text: $text)
            .focused(isFocused)
            .textStyle(.body1Regular)
            .foregroundStyle(Color.foregroundPrimary)
            .frame(height: 140)
            .overlay(placeholder, alignment: .topLeading)
    }

    @ViewBuilder
    private var placeholder: some View {
        if text.isEmpty {
            Text("Add your notes")
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundMinor)
                .padding(.horizontal, DSSpacing.s16)
                .padding(.vertical, DSSpacing.s16)
                .allowsHitTesting(false)
        }
    }
}
