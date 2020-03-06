--

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE public.account_type AS ENUM (
    'cheque',
    'savings',
    'credit'
);

CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.accounts (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    balance MONEY NOT NULL,
    type public.account_type NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES public.customers,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.transactions (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    delta MONEY NOT NULL,
    account_id INTEGER NOT NULL REFERENCES public.accounts,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_timestamp_customers
BEFORE UPDATE ON public.customers
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TRIGGER set_timestamp_accounts
BEFORE UPDATE ON public.accounts
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TRIGGER set_timestamp_transactions
BEFORE UPDATE ON public.transactions
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();