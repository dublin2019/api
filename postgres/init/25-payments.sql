SET ROLE members;

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    created timestamptz NOT NULL DEFAULT now(),
    updated timestamptz,
    payment_email text,
    status text,
    stripe_charge_id text,
    stripe_receipt text,
    stripe_token text,
    error text,
    amount integer NOT NULL,
    currency text NOT NULL,
    person_id integer REFERENCES People,
    person_name text,
    category text NOT NULL,
    type text,
    data jsonb,
    invoice text,
    comments text
);

CREATE TYPE StripeKeyType AS ENUM ('pk_live','pk_test');
CREATE TABLE stripe_keys (
    name text NOT NULL,
    type StripeKeyType NOT NULL,
    key text NOT NULL
);
INSERT INTO stripe_keys (name, type, key) VALUES
('default','pk_test','pk_test_iBToTP83RNFucaHfo2h6c0C5'),
('default','pk_live','pk_live_kgm8UwSDEVaW8Wkd90X651fd'),
('worldcon79','pk_test','pk_test_xxxxxx'),
('worldcon79','pk_live','pk_live_xxxxxx');
