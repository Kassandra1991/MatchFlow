# MatchFlow — Coding Rules

## Swift / SwiftUI
- Always use async/await, never callbacks
- @MainActor on all ViewModels
- import Combine on every ObservableObject
- Codable structs for all DB models with CodingKeys matching snake_case DB columns
- Never put business logic in Views
- Use .task {} for async calls in Views, not .onAppear

## Supabase
- Always use RLS — every table has policies
- Use uuid.uuidString when passing UUIDs to Supabase queries
- Embeddings stored as vector string: "[0.1,0.2,...]"
- Never use service_role key in client code

## AI / OpenAI
- Model for embeddings: text-embedding-3-large (3072 dimensions)
- Model for analysis: gpt-4o-mini (cheap, fast)
- Always request JSON response format for structured outputs
- Cache embeddings — never re-embed same text twice

## Git
- Branch: dev for development, main for stable
- Commit format: "feat:", "fix:", "refactor:", "security:"
- Never commit Secrets.swift or SupabaseConfig.swift
- Always check git status before committing

## File naming
- Views: FeatureNameView.swift
- ViewModels: FeatureNameViewModel.swift
- Services: FeatureNameService.swift
- Models: ModelName.swift (singular)

## Error handling
- Always wrap Supabase calls in do/catch
- Show errorMessage via @Published var errorMessage
- Never force unwrap optionals except URL(string:) with known valid strings

## Share Extension
- No Supabase imports in extension — use UserDefaults shared container only
- App Group: group.com.asichka.matchflow
- Keys: pendingJobURL, pendingJobText
