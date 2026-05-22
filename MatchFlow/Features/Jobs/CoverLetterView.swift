//
//  CoverLetterView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 13/05/2026.
//

import SwiftUI

struct CoverLetterView: View {
    let coverLetter: String
    let onRegenerate: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(coverLetter)
                    .font(.body)
                    .padding()
            }
            .navigationTitle("Cover Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIPasteboard.general.string = coverLetter
                        copied = true
                        AnalyticsService.log(.coverLetterCopied)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    } label: {
                        Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    onRegenerate()
                    dismiss()
                } label: {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
}
