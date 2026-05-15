# Protocols — JobMatch

## When to add a protocol

Add a protocol ONLY when:
- The concrete class makes network calls (Supabase, OpenAI)
- You need a mock for testing
- There are or will be multiple implementations

Do NOT add a protocol for:
- Pure functions (calculateMatchScore)
- Simple data transformations
- ViewModels
- Models

## Pattern

### 1. Define protocol
```swift
protocol JobServiceProtocol {
    func fetchJobs(userId: UUID) async throws -> [Job]
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?) async throws -> Job
    func updateStatus(jobId: UUID, status: JobStatus) async throws
    func updateMatchScore(jobId: UUID, score: Double) async throws
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws
    func fetchJob(jobId: UUID) async throws -> Job
    func saveCoverLetter(jobId: UUID, coverLetter: String) async throws
    func saveAnalysis(jobId: UUID, analysis: JobAnalysis, rawText: String?) async throws
    func checkPendingJob() -> (url: String?, text: String?)
}
```

### 2. Conform concrete class
```swift
class JobService: JobServiceProtocol {
    static let shared = JobService()
    // existing implementation unchanged
}
```

### 3. Inject in ViewModel
```swift
@MainActor
class JobsViewModel: ObservableObject {
    private let jobService: JobServiceProtocol
    
    init(jobService: JobServiceProtocol = JobService.shared) {
        self.jobService = jobService
    }
}
```

### 4. Mock for tests
```swift
class MockJobService: JobServiceProtocol {
    var jobs: [Job] = []
    var shouldThrow = false
    
    func fetchJobs(userId: UUID) async throws -> [Job] {
        if shouldThrow { throw TestError.mock }
        return jobs
    }
    // implement other methods with minimal stubs
}
```

## Current services that need protocols

| Service | Protocol needed | Reason |
|---------|----------------|--------|
| JobService | ✅ Yes | Supabase calls |
| ResumeService | ✅ Yes | Supabase calls |
| AIService | ✅ Yes | OpenAI calls |
| ProfileService | ✅ Yes | Supabase calls |

## Rules

- Protocol name = ServiceName + Protocol (e.g. JobServiceProtocol)
- Mock name = Mock + ServiceName (e.g. MockJobService)
- Mock lives in test target only, never in main app
- Protocol lives next to the concrete class in Services/
- Always provide default value in ViewModel init: `= JobService.shared`
