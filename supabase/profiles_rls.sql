-- Enable RLS for profiles table and allow each user to manage only their row.
-- Run this in Supabase SQL Editor after creating the profiles table.

alter table public.profiles enable row level security;

create policy "Profiles are viewable by owner"
on public.profiles
for select
using (auth.uid() = id);

create policy "Profiles are insertable by owner"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "Profiles are updatable by owner"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "Profiles are deletable by owner"
on public.profiles
for delete
using (auth.uid() = id);
