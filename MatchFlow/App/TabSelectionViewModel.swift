//
//  TabSelectionViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine

@MainActor
class TabSelectionViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var jobsFilter: JobStatus? = nil
}
