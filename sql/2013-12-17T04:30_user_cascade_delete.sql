ALTER TABLE "public".link_user_subscription
DROP CONSTRAINT "link_user_subscription_user_id_fkey",
ADD CONSTRAINT "link_user_subscription_user_id_fkey" 
FOREIGN KEY ("user_id") 
REFERENCES "public"."user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "public".user_registration_token
DROP CONSTRAINT "user_registration_token_link_user_subscription_id_fkey",
ADD CONSTRAINT "user_registration_token_link_user_subscription_id_fkey" 
FOREIGN KEY ("link_user_subscription_id") 
REFERENCES "public"."link_user_subscription" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "public".user_registration_token
DROP CONSTRAINT user_registration_token_user_id_fkey,
ADD CONSTRAINT "user_registration_token_user_id_fkey" 
FOREIGN KEY ("user_id") 
REFERENCES "public"."user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;