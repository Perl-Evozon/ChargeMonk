truncate table campaign;
ALTER TABLE "public".campaign ADD COLUMN subscription_id INTEGER REFERENCES "subscription"(id) ;
ALTER TABLE "public".campaign ADD COLUMN user_id INTEGER NOT NULL REFERENCES "user"(id) ;
ALTER TABLE "public".code ADD COLUMN redeem_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL;
ALTER TABLE "public".code DROP COLUMN username;
ALTER TABLE "public".code ADD COLUMN user_id INTEGER REFERENCES "user"(id) ;