INSERT INTO "public"."theme" VALUES ('1', 'Default', 'default/style.css', 'default/thumb.jpg', 'f');
ALTER TABLE "public".user ADD COLUMN profile_picture VARCHAR(250) DEFAULT NULL;
ALTER TABLE "public".user DROP COLUMN photo_id;
DROP TABLE "public".user_photo;
