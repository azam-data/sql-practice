-- ============================================================
-- WEEK 9: JSON FUNCTIONS (PostgreSQL / Supabase)
-- Concepts: Storing, querying, and extracting from JSON columns
-- ============================================================

-- SETUP: Create a mock table with a JSON column
--        (simulating an API event log or config store)
CREATE TEMP TABLE api_events (
    event_id   SERIAL PRIMARY KEY,
    event_time TIMESTAMPTZ DEFAULT NOW(),
    event_type TEXT,
    payload    JSONB
);

INSERT INTO api_events (event_type, payload) VALUES
('login',      '{"user_id": "C001", "device": "iPad", "ip": "103.12.4.5", "success": true}'),
('login',      '{"user_id": "C003", "device": "iPhone", "ip": "185.22.1.9", "success": true}'),
('transfer',   '{"user_id": "C001", "from_account": "A001", "to_account": "A003", "amount": 25000, "currency": "BDT"}'),
('failed_login','{"user_id": "C007", "device": "Desktop", "ip": "192.168.1.1", "success": false, "attempts": 3}'),
('transfer',   '{"user_id": "C005", "from_account": "A006", "to_account": "A014", "amount": 500000, "currency": "BDT"}'),
('login',      '{"user_id": "C010", "device": "Android", "ip": "103.44.2.7", "success": true}');


-- 1. Extract a field using -> (returns JSON) and ->> (returns text)
SELECT
    event_id,
    event_type,
    payload -> 'user_id'     AS user_id_json,   -- returns JSON: "C001"
    payload ->> 'user_id'    AS user_id_text,   -- returns text: C001
    payload ->> 'device'     AS device
FROM api_events;


-- 2. Filter on a JSON field value
SELECT *
FROM api_events
WHERE payload ->> 'success' = 'true';

-- Failed logins only
SELECT event_id, payload ->> 'user_id' AS user_id, event_time
FROM api_events
WHERE event_type = 'failed_login';


-- 3. Extract nested/numeric values
SELECT
    event_id,
    payload ->> 'user_id'  AS user_id,
    (payload ->> 'amount')::numeric AS transfer_amount,
    payload ->> 'currency' AS currency
FROM api_events
WHERE event_type = 'transfer';


-- 4. Check if a key exists in JSON
SELECT event_id, event_type
FROM api_events
WHERE payload ? 'amount';   -- ? operator: does this key exist?


-- 5. Aggregate: count events by device type
SELECT
    payload ->> 'device'  AS device,
    COUNT(*)              AS event_count
FROM api_events
WHERE payload ? 'device'
GROUP BY payload ->> 'device'
ORDER BY event_count DESC;


-- 6. jsonb_each: expand all key-value pairs of a JSON object into rows
SELECT event_id, key, value
FROM api_events, jsonb_each(payload)
WHERE event_id = 1;


-- 7. Build a JSON object in output
SELECT
    account_id,
    account_type,
    balance,
    jsonb_build_object(
        'account', account_id,
        'type', account_type,
        'balance', balance,
        'currency', currency
    ) AS account_json
FROM accounts
LIMIT 5;


-- PRACTICE EXERCISES:
-- Ex 1: Find all transfer events where amount > 100000
-- Ex 2: Count how many logins came from each device type
-- Ex 3: Add a new JSON event of type 'balance_check' with your own payload,
--       then query it back out
