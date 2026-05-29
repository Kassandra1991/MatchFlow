# MatchFlow — AI-Powered Job Search Tracker

> iOS app that helps professionals track job applications, understand where they match, and optimize their job search through AI analysis and structured memory.

## Features

- **Smart Job Tracking** — add jobs via Share Extension from Safari/LinkedIn or manually
- **AI Match Scoring** — semantic similarity between your resume and job descriptions using RAG
- **AI Job Analysis** — automatic extraction of title, company, required skills, seniority level
- **Resume Management** — upload a PDF resume — uploading a new one replaces the previous
- **Dashboard** — overview of applications by status, weekly activity, top matches
- **Status Tracking** — applied / interview / rejected / offer with color coding

## Tech Stack

**iOS**
- SwiftUI, PDFKit, Share Extension, App Groups
- MVVM architecture, async/await, Combine

**Backend**
- Supabase (PostgreSQL + pgvector)
- Row Level Security, Database triggers
- RESTful API via Supabase Swift SDK

**AI**
- OpenAI API (text-embedding-3-large, gpt-4o-mini)
- RAG pipeline — vector embeddings + cosine similarity
- Semantic job-resume matching

## Architecture
MatchFlow/
├── App/                    # Entry point, tab navigation
├── Features/
│   ├── Auth/               # Supabase Auth
│   ├── Dashboard/          # Overview, stats, top matches
│   ├── Jobs/               # Job list, filters, detail view
│   └── Resume/             # PDF upload, resume management
├── Models/                 # Codable data models
└── Services/               # AI, Jobs, Resume — Supabase calls
MatchFlowShare/             # Share Extension

## RAG Pipeline
Resume PDF → PDFKit text extraction → OpenAI embedding (3072d) → pgvector
Job Description → OpenAI embedding (3072d) → pgvector
Match Score = cosine_similarity(resume_embedding, job_embedding)

## Setup

1. Clone the repo
2. Create a Supabase project and run the SQL schema (see `/supabase/schema.sql`)
3. Copy `Secrets.example.swift` → `Secrets.swift` and add your keys:
```swift
enum Secrets {
    static let openAIKey = ""
    static let supabaseURL = ""
    static let supabaseKey = ""
}
```
4. Build and run in Xcode

## Status

MVP Phase 1 complete. Actively in development.

---

Built with SwiftUI + Supabase + OpenAI

