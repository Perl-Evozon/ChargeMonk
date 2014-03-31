BEGIN;

        CREATE TYPE discount AS ENUM (
            'unit',
            'percent'
        );

    alter table  link_user_subscription   add column   active                      BOOLEAN DEFAULT FALSE NOT NULL;
    alter table  link_user_subscription   add column   discount_code               VARCHAR(30);

    
    alter table campaign add column   discount_type               discount;
    alter table campaign add column   discount_amount             INTEGER NOT NULL;
    
    ALTER TABLE user_registration_token drop column subscription_id;
    alter table user_registration_token add column link_user_subscription_id INTEGER NOT NULL REFERENCES link_user_subscription(id);
    
    
    CREATE TABLE stripe_user (
	id                          SERIAL PRIMARY KEY REFERENCES "user"(id),
        card_token                  VARCHAR(50) NOT NULL,
	user_id                     VARCHAR(30)
	);
        
    CREATE TABLE braintree_user (
	id                          SERIAL PRIMARY KEY,
        card_token                  VARCHAR(50) NOT NULL,
	user_id                     INTEGER NOT NULL REFERENCES "user"(id)
	);
    
    CREATE TABLE invoice (
        id                          SERIAL PRIMARY KEY,
        invoice_id                  VARCHAR(20) UNIQUE NOT NULL,
        link_user_subscription_id   INTEGER NOT NULL REFERENCES "link_user_subscription"(id),
        user_id                     INTEGER NOT NULL REFERENCES "user"(id),
        gateway                     VARCHAR(50),
        remaining_amount            INTEGER,
        charge                      INTEGER NOT NULL
    );
    
    CREATE TABLE transaction (
        id                          SERIAL PRIMARY KEY,
        user_id                     INTEGER NOT NULL REFERENCES "user"(id),
        link_user_subscription_id   INTEGER NOT NULL REFERENCES "link_user_subscription"(id),
        gateway                     VARCHAR(50),
        tranzaction_id              VARCHAR(20),
        created                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
        amount                      INTEGER NOT NULL,
        success                     BOOLEAN DEFAULT FALSE NOT NULL,
        action                      VARCHAR(50),
        response_text               VARCHAR(500)
    );
    
COMMIT;
