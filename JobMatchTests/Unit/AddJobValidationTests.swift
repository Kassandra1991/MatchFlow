//
//  AddJobValidationTests.swift
//  MatchFlow
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("AddJobValidation")
struct AddJobValidationTests {
    @Test("Short placeholder text is insufficient")
    func shortTextInsufficient() {
        #expect(AddJobLayout.isDescriptionSufficient("Test") == false)
    }

    @Test("299 characters is insufficient")
    func justBelowMinimum() {
        let text = String(repeating: "a", count: 299)
        #expect(AddJobLayout.isDescriptionSufficient(text) == false)
    }

    @Test("300 characters is sufficient")
    func minimumLength() {
        let text = String(repeating: "a", count: 300)
        #expect(AddJobLayout.isDescriptionSufficient(text) == true)
    }

    @Test("Trimmed whitespace counts toward minimum")
    func trimsWhitespace() {
        let core = String(repeating: "a", count: 300)
        #expect(AddJobLayout.isDescriptionSufficient("  \(core)  ") == true)
    }
}
