-- Run once in your Supabase SQL Editor. The service key stays server-side.
create table if not exists public.portfolio_state (id integer primary key check (id=1), data jsonb not null, revision integer not null default 1);
create table if not exists public.media (id text primary key, name text not null, type text not null, size integer not null);
create table if not exists public.login_attempts (id text primary key, started timestamptz not null default now(), attempts integer not null default 0);
alter table public.portfolio_state enable row level security;
alter table public.media enable row level security;
alter table public.login_attempts enable row level security;
revoke all on public.portfolio_state,public.media,public.login_attempts from anon,authenticated;
grant all on public.portfolio_state,public.media,public.login_attempts to service_role;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values ('artwork','artwork',false,3145728,array['image/png','image/jpeg','image/webp']) on conflict (id) do nothing;
create or replace function public.save_portfolio(next_data jsonb,expected_revision integer) returns integer language plpgsql security invoker as $$
declare saved integer;
begin
 if expected_revision=0 then
  insert into public.portfolio_state(id,data,revision) values(1,next_data,1) on conflict do nothing returning revision into saved;
 else
  update public.portfolio_state set data=next_data,revision=revision+1 where id=1 and revision=expected_revision returning revision into saved;
 end if;
 return saved;
end; $$;
create or replace function public.allow_login_attempt(identity text) returns boolean language plpgsql security invoker as $$
declare attempt_count integer;
begin
 insert into public.login_attempts(id,started,attempts) values(identity,now(),1)
 on conflict(id) do update set started=case when login_attempts.started < now()-interval '15 minutes' then now() else login_attempts.started end,
 attempts=case when login_attempts.started < now()-interval '15 minutes' then 1 else login_attempts.attempts+1 end
 returning attempts into attempt_count;
 return attempt_count<=5;
end; $$;
revoke all on function public.save_portfolio(jsonb,integer) from public,anon,authenticated;
revoke all on function public.allow_login_attempt(text) from public,anon,authenticated;
grant execute on function public.save_portfolio(jsonb,integer),public.allow_login_attempt(text) to service_role;
