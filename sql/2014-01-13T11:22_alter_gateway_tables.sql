ALTER TABLE "public"."braintree_user" ADD COLUMN "card_type"  VARCHAR(30),  ADD COLUMN "last_four" varchar(4) DEFAULT NULL, ADD COLUMN"expiration_date" DATE;
ALTER TABLE "public"."stripe_user" ADD COLUMN "card_type"  VARCHAR(30), ADD COLUMN "last_four" varchar(4) DEFAULT NULL, ADD COLUMN "expiration_date" DATE;
