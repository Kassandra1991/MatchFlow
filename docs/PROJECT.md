# MatchFlow — Project Context

## What is MatchFlow
AI-powered career intelligence iOS app. Helps users track job applications, understand where they match, and see patterns in their job search.

## Current Status
MVP Phase 1 — Complete. Core RAG pipeline working end-to-end.

## What's Built
- Auth (Supabase Auth + email)
- Resume upload (PDF import → text extraction via PDFKit → OpenAI embedding → Supabase)
- Single resume per user (uploading a new one replaces the previous)
- Job tracking (manual add + Share Extension from Safari/LinkedIn)
- Share Extension captures URL/text → saves to shared UserDefaults → main app picks up on foreground
- AI job analysis (title, company, summary, skills, difficulty via gpt-4o-mini)
- Match scoring (cosine similarity between resume embedding and job embedding)
- Job Detail View — native List style, AI analysis, status picker, notes
- Status management (applied/interview/rejected/offer) with color coding

## Tech Stack
- iOS: SwiftUI, PDFKit
- Backend: Supabase (PostgreSQL + pgvector)
- AI: OpenAI API (text-embedding-3-large, gpt-4o-mini)
- Auth: Supabase Auth

## Architecture Pattern
MVVM + Services
- Views — UI only, no business logic, no direct Supabase access
- ViewModels — @MainActor, @Published state, user actions, inject services via protocols
- Services — Supabase, AI, and auth calls; sole layer that touches external APIs
- Shared — reusable UI styling and components (JobStatusStyle, MatchScoreStyle, StatusBadge)
- Models — Codable structs matching DB schema with CodingKeys

## File Structure
MatchFlow/
├── App/
│   ├── MatchFlowApp.swift          # Entry point
│   ├── MainTabView.swift           # Tab navigation (Jobs, Resume)
│   └── Secrets.swift               # API keys (gitignored)
├── Features/
│   ├── Auth/
│   │   ├── AuthViewModel.swift
│   │   └── AuthView.swift
│   ├── Jobs/
│   │   ├── JobsViewModel.swift
│   │   ├── JobsView.swift          # List + AddJobView + JobRowView + StatusBadge
│   │   ├── JobDetailView.swift     # Detail + AI analysis + status + notes
│   │   └── JobDetailViewModel.swift
│   └── Resume/
│       ├── ResumeViewModel.swift
│       └── ResumeView.swift        # List + AddResumeView + PDF import
├── Models/
│   ├── Job.swift                   # includes skillsRaw→skills computed property
│   ├── Resume.swift
│   └── JobSkill.swift
└── Services/
├── AIService.swift             # OpenAI embeddings + analysis + cosine similarity
├── JobService.swift            # Jobs CRUD + embeddings + match score + fetchJobText
└── ResumeService.swift         # Resume CRUD + embeddings (single resume per user)
MatchFlowShare/
└── ShareViewController.swift      # Share Extension — saves URL/text to App Group UserDefaults

## Database Schema (Supabase)
- users — id, email (auto-created via trigger on auth.users)
- resumes — id, user_id, title, raw_text, embedding(3072), is_default, created_at
- jobs — id, user_id, url, title, company, raw_text, embedding(3072), match_score, status, notes, summary, skills(text JSON), difficulty, applied_at, created_at
- job_skills — id, job_id, skill_name, is_missing, severity (planned)

## RAG Flow
1. User uploads resume → PDFKit extracts text → OpenAI embedding(3072) → save to resumes
2. User shares/adds job → text extracted → OpenAI embedding(3072) → save to jobs
3. Match score = cosine similarity (resume embedding vs job embedding) saved to jobs.match_score
4. AI analyzes job → extracts title, company, summary, skills[], difficulty → saved to jobs

## Known Limitations
- LinkedIn app blocks HTML parsing → only URL saved, no auto text extraction
- LinkedIn in Safari works via Share Extension (text selection → share)
- skills saved as JSON string in text column (not array) due to Supabase SDK limitations

## App Group
group.com.asichka.matchflow — shared container between app and Share Extension
Keys: pendingJobURL, pendingJobText

## Secrets (gitignored)
- Secrets.swift contains: openAIKey, supabaseURL, supabaseKey
- SupabaseConfig.swift also gitignored
- Never commit either file

## Next — Phase 2
- Insights dashboard (match patterns, skill gaps across jobs)
- Calendar heatmap (applications per day)
- Contacts/referrals
- LinkedIn OAuth for profile import
- Follow-up reminders
- Clipboard detection for LinkedIn URLs
