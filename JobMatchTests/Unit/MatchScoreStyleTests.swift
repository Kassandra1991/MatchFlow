//
//  MatchScoreStyleTests.swift
//  JobMatchTests
//

import Testing
@testable import MatchFlow

@Suite("MatchScoreTier detail titles")
struct MatchScoreStyleTests {
    @Test("Detail titles map to design labels")
    func detailTitles() {
        #expect(MatchScoreTier(score: 0.2).detailTitle == "Low match")
        #expect(MatchScoreTier(score: 0.5).detailTitle == "Moderate match")
        #expect(MatchScoreTier(score: 0.75).detailTitle == "Strong match")
        #expect(MatchScoreTier(score: 0.95).detailTitle == "Excellent match")
    }
}
