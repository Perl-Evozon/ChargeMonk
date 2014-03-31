CREATE TABLE "public"."authorize_user" (
"id" int4 DEFAULT nextval('stripe_user_id_seq'::regclass) NOT NULL,
"card_token" varchar(50) COLLATE "default" NOT NULL,
"user_id" int4 NOT NULL,
"customer_id" varchar(50) COLLATE "default" NOT NULL,
"card_type" varchar(30) COLLATE "default",
"last_four" varchar(4) COLLATE "default" DEFAULT NULL::character varying,
"expiration_date" date,
CONSTRAINT "authorize_user_pkey" PRIMARY KEY ("id"),
CONSTRAINT "authorize_user_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
);