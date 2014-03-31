CREATE TYPE user_type AS ENUM (
    'ADMIN',
    'CUSTOMER',
    'LEAD'
);

CREATE TABLE user_photo (
    id                          SERIAL PRIMARY KEY,
    photo                       BYTEA
);

CREATE TABLE "user" (
    id                          SERIAL PRIMARY KEY,
    firstname                   VARCHAR(100),
    lastname                    VARCHAR(100),
    email                       VARCHAR(50) UNIQUE NOT NULL,
    address                     VARCHAR(200),
    address2                    VARCHAR(200),
    country                     VARCHAR(50),
    state                       VARCHAR(50),
    zip_code                    VARCHAR(10),
    phone                       VARCHAR(15),
    photo_id                    INTEGER REFERENCES user_photo(id),
    gender                      VARCHAR(1),
    password                    VARCHAR(64),
    company_name                VARCHAR(100),
    company_address             VARCHAR(200),
    company_country             VARCHAR(50),
    company_state               VARCHAR(50),
    company_zip_code            VARCHAR(10),
    company_phone               VARCHAR(15),
    birthday                    DATE,
    signup_date                 DATE,
    type                        user_type DEFAULT 'LEAD' NOT NULL
);

CREATE TABLE user_psw_set_token (
    "uid"                       SERIAL PRIMARY KEY REFERENCES "user"(id),
    token                       VARCHAR(20) UNIQUE NOT NULL,
    created                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TYPE subscription_type AS ENUM (
    'regular',
    'promo'
);

CREATE TYPE subscription_access_type AS ENUM (
    'period',
    'period_users',
    'IP_range',
    'resources',
    'API_calls'
);

CREATE OR REPLACE FUNCTION varchar_to_subscription_access_type(chartoconvert character varying)
  RETURNS subscription_access_type AS
$BODY$
SELECT CAST( $1 AS subscription_access_type);
$BODY$
  LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE TYPE subscription_period_type AS ENUM (
    'Day',
    'Week',
    'Month',
    'Year'
);

CREATE TYPE currency_type AS ENUM (
    'EUR',
    'USD',
    'GBP',
    'RON',
    'XAU',
    'AUD',
    'CAD',
    'CHF',
    'CZK',
    'DKK',
    'EGP',
    'HUF',
    'JPY',
    'MDL',
    'NOK',
    'PLN',
    'SEK',
    'TRY',
    'XDR',
    'RUB',
    'BGN',
    'ZAR',
    'BRL',
    'CNY',
    'INR',
    'KRW',
    'MXN',
    'NZD',
    'RSD',
    'UAH',
    'AED'
);

CREATE TABLE subscription_group (
    id                          SERIAL PRIMARY KEY,
    name                        VARCHAR(40) UNIQUE NOT NULL,
    creation_date               TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TABLE subscription (
    id                          SERIAL PRIMARY KEY,
    name                        VARCHAR(40),
    type                        subscription_type,
    subscription_group_id       INTEGER REFERENCES subscription_group(id),
    is_visible                  BOOLEAN DEFAULT FALSE NOT NULL,
    require_company_data        BOOLEAN DEFAULT FALSE NOT NULL,
    has_auto_renew              BOOLEAN DEFAULT FALSE NOT NULL,
    access_type                 subscription_access_type,
    period                      INTEGER,
    price                       INTEGER,
    call_to_action              VARCHAR(30),
    has_trial                   BOOLEAN DEFAULT TRUE,
    min_active_period_users     INTEGER DEFAULT NULL,
    max_active_period_users     INTEGER DEFAULT NULL,
    position_in_group           INTEGER NOT NULL,
    currency                    currency_type,
    number_of_users             INTEGER,
    trial_period                INTEGER,
    trial_price                 INTEGER,
    trial_currency              currency_type,
    require_credit_card         BOOLEAN DEFAULT FALSE,
    created                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    created_by                  VARCHAR(80),
    period_count                INTEGER DEFAULT NULL,
    period_unit                 subscription_period_type DEFAULT NULL,
    trial_period_count          INTEGER DEFAULT NULL,
    trial_period_unit           subscription_period_type,
    resource_type               VARCHAR(40) DEFAULT NULL,
    min_resource_quantity       INTEGER DEFAULT NULL,
    max_resource_quantity       INTEGER DEFAULT NULL,
    min_active_ips              INTEGER DEFAULT NULL,
    max_active_ips              INTEGER DEFAULT NULL,
    api_calls_volume            INTEGER DEFAULT NULL
);
-- ALTER TABLE subscription ALTER COLUMN access_type TYPE subscription_access_type USING varchar_to_subscription_access_type(access_type);


CREATE TABLE subscription_downgrades_to (
    subscription_id             INTEGER NOT NULL,
    subscription_downgrade_id   INTEGER NOT NULL REFERENCES subscription(id)
);

CREATE TABLE subscription_upgrades_to (
    subscription_id             INTEGER NOT NULL,
    subscription_upgrade_id     INTEGER NOT NULL REFERENCES subscription(id)
);

CREATE TABLE link_user_subscription (
    id                          SERIAL PRIMARY KEY,
    user_id                     INTEGER NOT NULL REFERENCES "user"(id),
    subscription_id             INTEGER NOT NULL REFERENCES subscription(id),
    nr_of_period_users          INTEGER,
    active_from_date            TIMESTAMP WITH TIME ZONE NOT NULL,
    active_to_date              TIMESTAMP WITH TIME ZONE NOT NULL,
    active                      BOOLEAN DEFAULT FALSE NOT NULL,
    discount_code               VARCHAR(30)
);

CREATE TABLE period_user (
    id                          SERIAL PRIMARY KEY,
    link_user_subscription_id   INTEGER NOT NULL REFERENCES link_user_subscription(id),
    subscription_id             INTEGER NOT NULL REFERENCES subscription(id),
    first_name                  VARCHAR(30) NOT NULL,
    last_name                   VARCHAR(30) NOT NULL,
    email                       VARCHAR(50) NOT NULL,
    start_date                  TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    status                      BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE ip_range (
    id                          SERIAL PRIMARY KEY,
    link_user_subscription_id   INTEGER NOT NULL REFERENCES link_user_subscription(id),
    subscription_id             INTEGER NOT NULL REFERENCES subscription(id),
    from_ip                     VARCHAR(15) NOT NULL,
    to_ip                       VARCHAR(15) NOT NULL,
    start_date                  TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    status                      BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE feature (
    id                          SERIAL PRIMARY KEY,
    name                        VARCHAR(30) UNIQUE NOT NULL,
    description                 VARCHAR(200)
);

CREATE TABLE link_subscription_feature (
    subscription_id             INTEGER NOT NULL REFERENCES subscription(id),
    feature_id                  INTEGER NOT NULL REFERENCES feature(id)
);


CREATE TABLE code (
    id                          SERIAL PRIMARY KEY,
    campaign_id                 INTEGER NOT NULL,
    username                    VARCHAR(100),
    code                        VARCHAR(30)
);

CREATE TYPE discount AS ENUM (
    'unit',
    'percent'
);

CREATE TABLE campaign (
    id                          SERIAL PRIMARY KEY,
    name                        VARCHAR(50) NOT NULL,
    prefix                      VARCHAR(5) NOT NULL,
    nr_of_codes                 INTEGER DEFAULT 0 NOT NULL,
    start_date                  DATE,
    end_date                    DATE,
    discount_type               discount,
    discount_amount             INTEGER NOT NULL
);

CREATE TABLE link_campaigns_subscriptions (
    subscription_id             INTEGER NOT NULL,
    campaign_id                 INTEGER NOT NULL
);

CREATE TABLE theme (
    id                          SERIAL PRIMARY KEY,
    name                        VARCHAR(100) NOT NULL,
    css_file                    VARCHAR(128) NOT NULL,
    image_file                  VARCHAR(128) NOT NULL,
    active                      BOOLEAN DEFAULT FALSE
);

CREATE TABLE registration(
    id                          SERIAL PRIMARY KEY,
    sex                         BOOLEAN,
    first_name                  BOOLEAN,
    last_name                   BOOLEAN,
    date_of_birth               BOOLEAN,
    address                     BOOLEAN,
    address_2                   BOOLEAN,
    country                     BOOLEAN,
    state                       BOOLEAN,
    zip_code                    BOOLEAN,
    phone_number                BOOLEAN,
    company_name                BOOLEAN,
    company_address             BOOLEAN,
    company_country             BOOLEAN,
    company_state               BOOLEAN,
    company_zip_code            BOOLEAN,
    company_phone_number        BOOLEAN
);

CREATE TABLE user_registration_token (
    user_id                     SERIAL PRIMARY KEY REFERENCES "user"(id),
    link_user_subscription_id   INTEGER NOT NULL REFERENCES link_user_subscription(id) ON DELETE CASCADE,
    token                       VARCHAR(20) UNIQUE NOT NULL,
    flow_type                   VARCHAR(10),
    created                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL
);

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
    created                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
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

CREATE TABLE config (
    "key"                       varchar(255) COLLATE "default" NOT NULL,
    "value"                     varchar(255) COLLATE "default",
    CONSTRAINT "config_pkey"    PRIMARY KEY ("key")
);
