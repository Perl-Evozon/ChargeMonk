ALTER TABLE "public".link_user_subscription ADD COLUMN process_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW();
ALTER TABLE "public".link_user_subscription ADD COLUMN process_message VARCHAR(255);
ALTER TABLE "public".link_user_subscription ADD COLUMN process_status boolean;
