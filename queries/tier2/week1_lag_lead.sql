-- ============================================================
-- WEEK 1: LAG / LEAD
-- Tables used: transactions, accounts
-- Concepts: Access prior/next row values without self-join
-- ============================================================

-- 1. Basic LAG: Show each transaction and the previous transaction
--    amount for the same account
SELECT
    transaction_id,
    account_id,
    date,
    type,
    amount,
    LAG(amount, 1) OVER (
        PARTITION BY account_id
        ORDER BY date
    ) AS prev_amount
FROM transactions;


-- 2. Calculate amount change vs previous transaction (same account)
SELECT
    transaction_id,
    account_id,
    date,
    amount,
    LAG(amount) OVER (PARTITION BY account_id ORDER BY date) AS prev_amount,
    amount - LAG(amount) OVER (PARTITION BY account_id ORDER BY date) AS change
FROM transactions;


-- 3. LEAD: Show what the NEXT transaction amount will be
SELECT
    transaction_id,
    account_id,
    date,
    amount,
    LEAD(amount, 1) OVER (PARTITION BY account_id ORDER BY date) AS next_amount
FROM transactions;


-- 4. Practical: Flag accounts where the current deposit is more
--    than double the previous deposit (unusual activity signal)
WITH lag_data AS (
    SELECT
        transaction_id,
        account_id,
        date,
        amount,
        type,
        LAG(amount) OVER (PARTITION BY account_id ORDER BY date) AS prev_amount
    FROM transactions
    WHERE type = 'Deposit'
)
SELECT *
FROM lag_data
WHERE prev_amount IS NOT NULL
  AND amount > prev_amount * 2;


-- PRACTICE EXERCISES:
-- Ex 1: Find the number of days between each consecutive transaction per account
-- Ex 2: Show the transaction type that came just before each 'Withdrawal'
-- Ex 3: For each account, flag if the latest transaction amount is higher
--       than the one before it (use LAG with a default value of 0)
