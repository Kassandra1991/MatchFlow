# Testing — JobMatch

## Framework
Swift Testing (not XCTest)
import Testing

## File structure
JobMatchTests/
├── Unit/
│   ├── ViewModels/
│   │   ├── DashboardViewModelTests.swift
│   │   ├── JobsViewModelTests.swift
│   │   └── ProfileViewModelTests.swift
│   ├── Services/
│   │   └── AIServiceTests.swift
│   └── Models/
│       └── JobTests.swift
├── Mocks/
│   ├── MockJobService.swift
│   ├── MockResumeService.swift
│   ├── MockAIService.swift
│   └── MockProfileService.swift
└── Fixtures/
└── Extensions/
├── Job+Mock.swift
├── Resume+Mock.swift
└── UserProfile+Mock.swift

## Naming convention
```swift
@Test("Dashboard shows jobs added this week")
func jobsThisWeekCount() { }

@Test("Match score above 55% returns green color")
func matchScoreColorGreen() { }

@Test("Empty jobs list returns zero this week")
func emptyJobsThisWeek() { }
```

## Test fixtures — extensions with defaults
```swift
extension Job {
    static func mock(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        title: String? = "iOS Developer",
        company: String? = "Apple",
        rawText: String? = "Job description",
        matchScore: Double? = 0.75,
        status: JobStatus = .applied,
        summary: String? = nil,
        skills: [String] = [],
        difficulty: String? = nil,
        coverLetter: String? = nil,
        notes: String? = nil,
        url: String? = nil,
        appliedAt: Date = Date(),
        createdAt: Date = Date()
    ) -> Job {
        Job(
            id: id,
            userId: userId,
            url: url,
            title: title,
            company: company,
            rawText: rawText,
            matchScore: matchScore,
            status: status,
            notes: notes,
            summary: summary,
            skillsRaw: skills.isEmpty ? nil : (try? String(data: JSONEncoder().encode(skills), encoding: .utf8) ?? nil),
            difficulty: difficulty,
            coverLetter: coverLetter,
            appliedAt: appliedAt,
            createdAt: createdAt
        )
    }
}

extension Resume {
    static func mock(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        title: String = "My Resume",
        rawText: String? = "Experienced iOS developer",
        isDefault: Bool = true,
        createdAt: Date = Date()
    ) -> Resume {
        Resume(id: id, userId: userId, title: title, rawText: rawText, isDefault: isDefault, createdAt: createdAt)
    }
}

extension UserProfile {
    static func mock(
        id: UUID = UUID(),
        email: String = "test@test.com",
        fullName: String? = "Test User",
        headline: String? = "iOS Developer",
        importantInCompany: String? = "Good processes",
        workStyle: String? = "Remote",
        careerGoals: String? = "Grow as engineer",
        coverLetterTone: String? = "friendly"
    ) -> UserProfile {
        UserProfile(
            id: id, email: email, fullName: fullName,
            headline: headline, importantInCompany: importantInCompany,
            workStyle: workStyle, careerGoals: careerGoals,
            coverLetterTone: coverLetterTone
        )
    }
}
```

## Mock pattern
```swift
class MockJobService: JobServiceProtocol {
    // State
    var jobs: [Job] = []
    var shouldThrow = false
    
    // Call tracking
    var fetchJobsCalled = false
    var addJobCalled = false
    var lastAddedJobText: String?
    
    func fetchJobs(userId: UUID) async throws -> [Job] {
        fetchJobsCalled = true
        if shouldThrow { throw TestError.mock }
        return jobs
    }
    
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?) async throws -> Job {
        addJobCalled = true
        lastAddedJobText = rawText
        if shouldThrow { throw TestError.mock }
        let job = Job.mock(title: title, company: company, rawText: rawText)
        jobs.append(job)
        return job
    }
    
    // Stub remaining methods
    func updateStatus(jobId: UUID, status: JobStatus) async throws {}
    func updateMatchScore(jobId: UUID, score: Double) async throws {}
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws {}
    func fetchJob(jobId: UUID) async throws -> Job { Job.mock() }
    func saveCoverLetter(jobId: UUID, coverLetter: String) async throws {}
    func saveAnalysis(jobId: UUID, analysis: JobAnalysis, rawText: String?) async throws {}
    func checkPendingJob() -> (url: String?, text: String?) { (nil, nil) }
}

enum TestError: Error {
    case mock
}
```

## Example tests
```swift
import Testing
@testable import JobMatch

@Suite("DashboardViewModel")
struct DashboardViewModelTests {
    
    @Test("Jobs this week returns correct count")
    func jobsThisWeekCount() async {
        let viewModel = DashboardViewModel()
        let recentJob = Job.mock(createdAt: Date())
        let oldJob = Job.mock(createdAt: Date().addingTimeInterval(-8 * 24 * 60 * 60))
        viewModel.allJobs = [recentJob, oldJob]
        
        #expect(viewModel.jobsThisWeek == 1)
    }
    
    @Test("Top matches returns jobs sorted by score")
    func topMatchesSortedByScore() async {
        let viewModel = DashboardViewModel()
        let lowMatch = Job.mock(matchScore: 0.3)
        let highMatch = Job.mock(matchScore: 0.8)
        let midMatch = Job.mock(matchScore: 0.5)
        viewModel.allJobs = [lowMatch, highMatch, midMatch]
        
        #expect(viewModel.topMatches.first?.matchScore == 0.8)
    }
    
    @Test("Jobs for status filters correctly")
    func jobsForStatus() async {
        let viewModel = DashboardViewModel()
        viewModel.allJobs = [
            Job.mock(status: .applied),
            Job.mock(status: .applied),
            Job.mock(status: .interview)
        ]
        
        #expect(viewModel.jobs(for: .applied).count == 2)
        #expect(viewModel.jobs(for: .interview).count == 1)
        #expect(viewModel.jobs(for: .rejected).count == 0)
    }
}

@Suite("AIService")
struct AIServiceTests {
    
    @Test("Cosine similarity of identical vectors returns 1")
    func cosineSimilarityIdentical() {
        let vector: [Float] = [1.0, 0.0, 0.0]
        let score = AIService.shared.calculateMatchScore(
            resumeEmbedding: vector,
            jobEmbedding: vector
        )
        #expect(score == 1.0)
    }
    
    @Test("Cosine similarity of opposite vectors returns -1")
    func cosineSimilarityOpposite() {
        let score = AIService.shared.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [-1.0, 0.0]
        )
        #expect(score == -1.0)
    }
    
    @Test("Cosine similarity with empty vectors returns 0")
    func cosineSimilarityEmpty() {
        let score = AIService.shared.calculateMatchScore(
            resumeEmbedding: [],
            jobEmbedding: []
        )
        #expect(score == 0.0)
    }
}
```

## What to test vs skip

| Type | Test? | Reason |
|------|-------|--------|
| ViewModel computed properties | ✅ Yes | Pure logic |
| calculateMatchScore | ✅ Yes | Pure math |
| Job.skills computed property | ✅ Yes | JSON parsing |
| Supabase calls | ✅ Yes via mocks | Use MockService |
| OpenAI calls | ✅ Yes via mocks | Use MockAIService |
| SwiftUI Views | ❌ Skip | Fragile, low value |
| Share Extension | ❌ Skip | Hard to test |

## Coverage target
- Unit tests: aim for 70-80% of ViewModels and Services
- Focus on business logic, not boilerplate
- Run coverage: Xcode → Product → Test (with coverage enabled)
