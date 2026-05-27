-- ============================================================
-- WEEK 5: CAST, STRING FUNCTIONS, UNION
-- Tables used: all tables
-- Concepts: Type casting, string manipulation, combining result sets
-- ============================================================

-- SECTION A: CAST / CONVERT

-- 1. Cast date column stored as text to actual date type
SELECT
    transaction_id,
    date,
    date::date                         AS date_typed,
    date::date + INTERVAL '30 days'    AS date_plus_30
FROM transactions
LIMIT 5;

-- 2. Cast amount to integer (truncates decimals)
SELECT
    transaction_id,
    amount,
    amount::integer       AS amount_int,
    amount::numeric(15,2) AS amount_rounded
FROM transactions
LIMIT 5;

-- 3. Cast balance to text for concatenation
SELECT
    account_id,
    'Balance: ' || balance::text || ' ' || currency AS balance_label
FROM accounts;


-- SECTION B: STRING FUNCTIONS

-- 4. Clean up and standardise description column
SELECT
    transaction_id,
    description,
    UPPER(description)         AS upper_desc,
    LOWER(description)         AS lower_desc,
    TRIM(description)          AS trimmed,
    LENGTH(description)        AS char_count
FROM transactions
LIMIT 10;

-- 5. Extract first word of description (before first space)
SELECT
    description,
    SPLIT_PART(description, ' ', 1) AS first_word
FROM transactions;

-- 6. Replace text in descriptions
SELECT
    description,
    REPLACE(description, 'transfer', 'xfer') AS shortened
FROM transactions
WHERE LOWER(description) LIKE '%transfer%';

-- 7. Concatenate customer name with segment label
SELECT
    customer_id,
    full_name,
    segment,
    CONCAT(full_name, ' [', segment, ']') AS display_name
FROM customers;

-- 8. Substring: extract first 4 chars of account_id (branch code mock)
SELECT
    account_id,
    SUBSTRING(account_id, 1, 1) AS prefix,
    SUBSTRING(account_id, 2)    AS numeric_part
FROM accounts;


-- SECTION C: UNION / UNION ALL

-- 9. UNION ALL: Stack deposits and withdrawals into one list
SELECT 'Deposit' AS flow, transaction_id, account_id, date, amount
FROM transactions WHERE type = 'Deposit'
UNION ALL
SELECT 'Withdrawal', transaction_id, account_id, date, amount
FROM transactions WHERE type = 'Withdrawal'
ORDER BY date;

-- 10. UNION (removes duplicates): All cities from both customers and accounts
SELECT city AS location, 'Customer city' AS source FROM customers
UNION
SELECT branch, 'Account branch' FROM accounts
ORDER BY location;


-- PRACTICE EXERCISES:
-- Ex 1: Build a full display label: "T0001 | A001 | 2024-01-15 | Deposit | 45000.00 BDT"
-- Ex 2: Find all descriptions that start with 'Cash' or 'Salary'
-- Ex 3: Union all Premium and Corporate customer records into one result set
--       and add a 'tier' column showing which group each came from
