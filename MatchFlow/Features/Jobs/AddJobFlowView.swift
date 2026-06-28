//
//  AddJobFlowView.swift
//  MatchFlow
//

import SwiftUI

struct AddJobFlowView: View {
    @ObservedObject var viewModel: JobsViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabSelection: TabSelectionViewModel
    @State private var showManualAdd = false

    var body: some View {
        NavigationStack {
            AddJobImportView(
                viewModel: viewModel,
                userId: userId,
                onSuccess: handleAddSuccess,
                onManualAdd: { showManualAdd = true }
            )
            .navigationDestination(isPresented: $showManualAdd) {
                AddJobView(viewModel: viewModel, userId: userId, onSuccess: handleAddSuccess)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationBackground(Color.backgroundPrimary)
    }

    private func handleAddSuccess() {
        tabSelection.selectedTab = 1
        tabSelection.jobsFilter = nil
        dismiss()
    }
}
