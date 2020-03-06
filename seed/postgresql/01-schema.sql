--

CREATE TYPE public.account_type AS ENUM (
    'cheque',
    'savings',
    'credit'
);

CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT
);

CREATE TABLE public.accounts (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    balance MONEY NOT NULL,
    type public.account_type NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES public.customers
);

CREATE TABLE public.transactions (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    delta MONEY NOT NULL,
    account_id INTEGER NOT NULL REFERENCES public.accounts
);
