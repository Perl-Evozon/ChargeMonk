ALTER TABLE "public".stripe_user ADD COLUMN customer_id VARCHAR(50);
ALTER TABLE "public".stripe_user ALTER COLUMN user_id TYPE int4 USING (user_id::integer);
ALTER TABLE "public".stripe_user DROP CONSTRAINT "stripe_user_id_fkey", ADD CONSTRAINT "stripe_user_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;