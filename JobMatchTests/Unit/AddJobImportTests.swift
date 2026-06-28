//
//  AddJobImportTests.swift
//  JobMatchTests
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("AddJobImport")
struct AddJobImportTests {
    @Test("Valid http URL passes validation")
    func validHTTPURL() {
        #expect(AddJobImportLayout.isValidJobURL("https://www.linkedin.com/jobs/view/123456") == true)
    }

    @Test("Invalid URL fails validation")
    func invalidURL() {
        #expect(AddJobImportLayout.isValidJobURL("not-a-url") == false)
        #expect(AddJobImportLayout.isValidJobURL("") == false)
    }

    @Test("Whitespace is trimmed for validation")
    func trimmedValidation() {
        #expect(AddJobImportLayout.isValidJobURL("  https://example.com/job  ") == true)
    }
}
