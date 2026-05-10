
## Current Status
MVP Phase 1 — Backend + Core UI

## Tech Stack
- iOS: SwiftUI
- Backend: Supabase (PostgreSQL + pgvector)
- AI: OpenAI API (text-embedding-3-small, gpt-4o-mini)
- Auth: Supabase Auth

## Architecture Pattern
MVVM + Services
- Views — UI only, no business logic
- ViewModels — state, user actions
- Services — Supabase and AI calls
- Models — Codable structs matching DB schema

## File Structure MatchFlow/
├── App/
│   ├── MatchFlowApp.swift      # Entry point
│   ├── MainTabView.swift       # Tab navigation
│   └── Secrets.swift           # API keys (gitignored)
├── Features/
│   ├── Auth/
│   │   ├── AuthViewModel.swift
│   │   └── AuthView.swift
│   ├── Jobs/
│   │   ├── JobsViewModel.swift
│   │   ├── JobsView.swift
│   │   └── JobDetailView.swift (planned)
│   └── Resume/
│       ├── ResumeViewModel.swift
│       └── ResumeView.swift
├── Models/
│   ├── Job.swift
│   ├── Resume.swift
│   └── JobSkill.swift
└── Services/
├── AIService.swift         # OpenAI embeddings + analysis
├── JobService.swift        # Jobs CRUD + embeddings
└── ResumeService.swift     # Resume CRUD + embeddings
MatchFlowShare/
└── ShareViewController.swift  # Share Extension (Safari/LinkedIn)

## Database Schema (Supabase)
- users — auth via Supabase Auth
- resumes — id, user_id, title, raw_text, embedding(1536), is_default
- jobs — id, user_id, url, title, company, raw_text, embedding(1536), match_score, status, applied_at
- job_skills — id, job_id, skill_name, is_missing, severity

## RAG Flow
1. User uploads resume → extract text → OpenAI embedding → save to resumes
2. User shares job → extract text → OpenAI embedding → save to jobs
3. Match score = cosine similarity (resume embedding vs job embedding)
4. AI analyzes job description → extracts title, company, skills, difficulty

## App Group
group.com.asichka.matchflow — shared container between app and Share Extension

## Secrets (gitignored)
- Secrets.swift contains: openAIKey, supabaseURL, supabaseKey
- Never commit Secrets.swift

## Planned Features (Phase 2)
- Job detail view with AI analysis
- Skill gap detection
- Multiple resumes per user
- Insights dashboard
- Contacts/referrals

## Planned Features (Phase 3)
- LinkedIn OAuth
- Calendar heatmap
- Follow-up reminders
