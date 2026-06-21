//
//  InsightsView.swift
//  MatchFlow
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var jobsViewModel = JobsViewModel()
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var tabSelection: TabSelectionViewModel
    @State private var showAddManually = false
    @State private var selectedJobId: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundAccent
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        heroWithAddJob

                        VStack(spacing: DSSpacing.s32) {
                            InsightsTopMatchesSection(
                                isOnboarding: viewModel.isOnboarding,
                                jobs: viewModel.topMatches,
                                topMatchesInsight: viewModel.insights?.topMatchesInsight,
                                isLoadingInsights: viewModel.isLoadingInsights && !viewModel.isOnboarding,
                                onJobTap: { selectedJobId = $0 }
                            )

                            InsightsProgressSection(
                                exploredCount: progressCount(viewModel.exploredCount),
                                appliedCount: progressCount(viewModel.appliedCount),
                                interviewCount: progressCount(viewModel.interviewCount),
                                rejectedCount: progressCount(viewModel.rejectedCount),
                                offerCount: progressCount(viewModel.offerCount),
                                onExploredTap: { openJobs(filter: .exploring) },
                                onAppliedTap: { openJobs(filter: .applied) },
                                onInterviewTap: { openJobs(filter: .interview) },
                                onRejectedTap: { openJobs(filter: .rejected) },
                                onOfferTap: { openJobs(filter: .offer) }
                            )
                        }
                        .padding(.horizontal, DSSpacing.s16)
                        .padding(.top, InsightsHeroLayout.addJobToTopMatchesSpacing)
                    }
                    .padding(.bottom, DSSpacing.s32)
                    .background(alignment: .top) {
                        InsightsScrollBackground()
                    }
                }
                .scrollContentBackground(.hidden)
                .ignoresSafeArea(edges: .top)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedJobId) { jobId in
                if let job = viewModel.allJobs.first(where: { $0.id == jobId }) {
                    JobDetailView(job: job)
                }
            }
            .sheet(isPresented: $showAddManually, onDismiss: reloadAfterAdd) {
                AddJobView(viewModel: jobsViewModel, userId: auth.currentUserId)
            }
            .task {
                await reload()
            }
            .refreshable {
                await reload()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task { await reload() }
            }
        }
    }

    private var heroWithAddJob: some View {
        ZStack(alignment: .bottom) {
            InsightsHeroView(
                isOnboarding: viewModel.isOnboarding,
                adviceText: viewModel.insights?.summary,
                isLoadingAdvice: viewModel.isLoadingInsights && !viewModel.isOnboarding
            )

            InsightsAddJobCard {
                showAddManually = true
            }
            .padding(.horizontal, DSSpacing.s16)
            .offset(y: InsightsHeroLayout.addJobCardOverlap)
        }
        .padding(.bottom, InsightsHeroLayout.addJobCardOverlap)
    }

    private func progressCount(_ count: Int) -> Int {
        viewModel.isOnboarding ? 0 : count
    }

    private func openJobs(filter: JobStatus) {
        tabSelection.selectedTab = 1
        tabSelection.jobsFilter = filter
    }

    private func reload() async {
        if let userId = auth.currentUserId {
            await viewModel.load(userId: userId)
        }
    }

    private func reloadAfterAdd() {
        Task {
            if let userId = auth.currentUserId {
                await viewModel.load(userId: userId)
            }
        }
    }
}

/// Scrolling hero PNG — fit width, natural height from aspect ratio (470×1024).
private struct InsightsScrollBackground: View {
    var body: some View {
        Image("InsightsHeroBackground")
            .resizable()
            .aspectRatio(InsightsHeroLayout.heroBackgroundAspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    InsightsView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabSelectionViewModel())
}
