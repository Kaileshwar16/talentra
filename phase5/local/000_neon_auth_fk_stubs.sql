-- Local-only compatibility objects for the two foreign keys in phased migrations.
-- These tables do not implement Neon Auth and must not be used for authentication.
CREATE SCHEMA neon_auth;
CREATE TABLE neon_auth."user" (id UUID PRIMARY KEY);
CREATE TABLE neon_auth.session (id UUID PRIMARY KEY);
