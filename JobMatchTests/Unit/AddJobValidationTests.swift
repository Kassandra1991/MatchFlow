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

    @Test("Empty text has 300 characters remaining")
    func emptyTextRemaining() {
        #expect(AddJobLayout.charactersRemaining("") == 300)
        #expect(AddJobLayout.charactersRemainingMessage("") == nil)
    }

    @Test("Partial text shows remaining count message")
    func partialTextMessage() {
        let text = String(repeating: "a", count: 173)
        #expect(AddJobLayout.charactersRemaining(text) == 127)
        #expect(AddJobLayout.charactersRemainingMessage(text) == "Need 127 more characters")
    }

    @Test("One character remaining uses singular message")
    func singularRemainingMessage() {
        let text = String(repeating: "a", count: 299)
        #expect(AddJobLayout.charactersRemaining(text) == 1)
        #expect(AddJobLayout.charactersRemainingMessage(text) == "Need 1 more character")
    }

    @Test("Sufficient text has no remaining message")
    func sufficientTextNoMessage() {
        let text = String(repeating: "a", count: 300)
        #expect(AddJobLayout.charactersRemaining(text) == 0)
        #expect(AddJobLayout.charactersRemainingMessage(text) == nil)
    }
}
