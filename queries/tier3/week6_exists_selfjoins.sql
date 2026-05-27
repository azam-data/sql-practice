-- ============================================================
-- WEEK 6: EXISTS / NOT EXISTS + SELF-JOINS
-- Tables used: transactions, accounts, customers
-- ============================================================

-- SECTION A: EXISTS / NOT EXISTS

-- 1. Find customers who HAVE made at least one transaction
SELECT c.customer_id, c.full_name, c.segment
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE a.customer_id = c.customer_id
);

-- 2. Find customers with NO transactions at all
SELECT c.customer_id, c.full_name, c.segment
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE a.customer_id = c.customer_id
);

-- 3. Accounts that received a Deposit but NEVER had a Fee charged
SELECT a.account_id, a.account_type
FROM accounts a
WHERE EXISTS (
    SELECT 1 FROM transactions t
    WHERE t.account_id = a.account_id AND t.type = 'Deposit'
)
AND NOT EXISTS (
    SELECT 1 FROM transactions t
    WHERE t.account_id = a.account_id AND t.type = 'Fee'
);

-- 4. EXISTS vs IN — same result, different performance
--    Use EXISTS for large tables; IN fine for small lookup sets

-- Using IN (fine here, small dataset):
SELECT * FROM accounts
WHERE customer_id IN (SELECT customer_id FROM customers WHERE segment = 'Premium');

-- Using EXISTS (preferred at scale):
SELECT a.*
FROM accounts a
WHERE EXISTS (
    SELECT 1 FROM customers c
    WHERE c.customer_id = a.customer_id
    AND c.segment = 'Premium'
);


-- SECTION B: SELF-JOINS

-- 5. Compare each account's balance to every other account
--    of the same type (peer comparison)
SELECT
    a1.account_id,
    a1.account_type,
    a1.balance        AS this_balance,
    a2.account_id     AS peer_account,
    a2.balance        AS peer_balance,
    a1.balance - a2.balance AS balance_diff
FROM accounts a1
JOIN accounts a2
    ON a1.account_type = a2.account_type
    AND a1.account_id <> a2.account_id
ORDER BY a1.account_type, a1.account_id;

-- 6. Find pairs of transactions on the same account on the same date
SELECT
    t1.transaction_id AS tx1,
    t2.transaction_id AS tx2,
    t1.account_id,
    t1.date,
    t1.type AS type1,
    t2.type AS type2,
    t1.amount AS amt1,
    t2.amount AS amt2
FROM transactions t1
JOIN transactions t2
    ON t1.account_id = t2.account_id
    AND t1.date = t2.date
    AND t1.transaction_id < t2.transaction_id  -- avoid duplicates
ORDER BY t1.account_id, t1.date;

-- 7. Self-join to find consecutive transactions where
--    amount increased (similar to LAG but via join technique)
SELECT
    t1.transaction_id,
    t1.account_id,
    t1.date      AS earlier_date,
    t1.amount    AS earlier_amount,
    t2.date      AS later_date,
    t2.amount    AS later_amount
FROM transactions t1
JOIN transactions t2
    ON t1.account_id = t2.account_id
    AND t2.date > t1.date
    AND t2.amount > t1.amount
ORDER BY t1.account_id, t1.date;


-- PRACTICE EXERCISES:
-- Ex 1: Find all accounts that had both a Deposit AND a Withdrawal in the same month
-- Ex 2: List customers who opened more than one account (self-join on accounts)
-- Ex 3: Find accounts where the most recent transaction was a Fee (use NOT EXISTS)
