//
//  CompanyLogoURLTests.swift
//  JobMatchTests
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("CompanyLogoURL")
struct CompanyLogoURLTests {
    @Test("Company logo URLs are accepted")
    func acceptsCompanyLogo() {
        let url = URL(string: "https://media.licdn.com/dms/image/C4E0BAQH/example/company-logo_200_200/0")!
        #expect(!CompanyLogoURL.isLikelyJobSharePreview(url))
        #expect(CompanyLogoURL.normalizedDisplayURL(from: url.absoluteString) != nil)
    }

    @Test("LinkedIn share preview URLs are rejected")
    func rejectsSharePreview() {
        let url = URL(string: "https://static.licdn.com/scds/common/u/images/logos/favicons/v1/opengraph/opengraph-share.png")!
        #expect(CompanyLogoURL.isLikelyJobSharePreview(url))
        #expect(CompanyLogoURL.normalizedDisplayURL(from: url.absoluteString) == nil)
    }
}
