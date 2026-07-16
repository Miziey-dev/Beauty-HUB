-- Screen 8 (Profile / Settings) needs saved addresses and a notification
-- preference; both are thin enough to live directly on profiles for MVP.
alter table profiles
  add column saved_addresses jsonb not null default '[]',
  add column push_notifications_enabled boolean not null default true;
