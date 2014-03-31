ALTER TABLE "public".user DROP COLUMN signup_date;
ALTER TABLE "public".user DROP COLUMN signup_time;
ALTER TABLE "public".user ADD COLUMN signup_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
