-- Enable pgvector
create extension if not exists vector;

-- Users (auto-created via trigger)
create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  created_at timestamp default now()
);

-- Resumes
create table resumes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  title text default 'My Resume',
  raw_text text,
  skills text,
  years_experience int,
  seniority text,
  embedding vector(3072),
  is_default boolean default true,
  created_at timestamp default now()
);

-- Jobs
create table jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  url text,
  title text,
  company text,
  raw_text text,
  embedding vector(3072),
  match_score float,
  experience_score float,
  skills_coverage float,
  level_fit float,
  status text default 'applied',
  notes text,
  summary text,
  skills text,
  difficulty text,
  applied_at timestamp default now(),
  created_at timestamp default now()
);

-- Job Skills
create table job_skills (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references jobs(id),
  skill_name text,
  is_missing boolean default false,
  severity text default 'medium'
);

-- Enable RLS
alter table users enable row level security;
alter table resumes enable row level security;
alter table jobs enable row level security;
alter table job_skills enable row level security;

-- RLS Policies
create policy "users_own" on users for all using (auth.uid() = id);
create policy "resumes_own" on resumes for all using (auth.uid() = user_id);
create policy "jobs_own" on jobs for all using (auth.uid() = user_id);
create policy "job_skills_own" on job_skills for all using (
  exists (select 1 from jobs where jobs.id = job_skills.job_id and jobs.user_id = auth.uid())
);

-- Trigger: auto-create user on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Match function
create or replace function match_jobs(
  query_embedding vector(3072),
  match_threshold float default 0.5,
  match_count int default 10
)
returns table (id uuid, title text, company text, match_score float)
language sql stable as $$
  select id, title, company,
    1 - (embedding <=> query_embedding) as match_score
  from jobs
  where 1 - (embedding <=> query_embedding) > match_threshold
  order by match_score desc
  limit match_count;
$$;
