//
//  AIServiceTests.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 17/05/2026.
//

import Testing
@testable import MatchFlow

@Suite("AIService")
struct AIServiceTests {
    
    let service = AIService()
    
    @Test("Cosine similarity of identical vectors returns 1")
    func cosineSimilarityIdentical() {
        let vector: [Float] = [1.0, 0.0, 0.0]
        let score = service.calculateMatchScore(
            resumeEmbedding: vector,
            jobEmbedding: vector
        )
        #expect(score == 1.0)
    }
    
    @Test("Cosine similarity of opposite vectors returns -1")
    func cosineSimilarityOpposite() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [-1.0, 0.0]
        )
        #expect(score == -1.0)
    }
    
    @Test("Cosine similarity with empty vectors returns 0")
    func cosineSimilarityEmpty() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [],
            jobEmbedding: []
        )
        #expect(score == 0.0)
    }
    
    @Test("Cosine similarity with mismatched vector sizes returns 0")
    func cosineSimilarityMismatch() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [1.0, 0.0, 0.0]
        )
        #expect(score == 0.0)
    }
    
    @Test("Cosine similarity of orthogonal vectors returns 0")
    func cosineSimilarityOrthogonal() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [0.0, 1.0]
        )
        #expect(abs(score) < 0.0001)
    }
}
