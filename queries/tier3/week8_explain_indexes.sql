-- ============================================================
-- WEEK 8: EXPLAIN + INDEXES
-- Concepts: Reading query plans, identifying slow operations,
--           index types, when indexes help vs hurt
-- ============================================================

-- SECTION A: EXPLAIN / EXPLAIN ANALYZE
-- EXPLAIN shows the planned execution without running the query
-- EXPLAIN ANALYZE actually runs it and shows real timings

-- 1. Basic EXPLAIN — read the plan
EXPLAIN
SELECT * FROM transactions WHERE account_id = 'A006';

-- 2. EXPLAIN ANALYZE — runs query, shows actual vs estimated rows
EXPLAIN ANALYZE
SELECT * FROM transactions WHERE account_id = 'A006';

-- 3. Compare: sequential scan vs index scan
--    Run EXPLAIN on both before and after creating an index (see below)
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE date::date BETWEEN '2024-03-01' AND '2024-06-30';

-- 4. EXPLAIN on a JOIN — see nested loop vs hash join
EXPLAIN ANALYZE
SELECT c.full_name, a.account_type, SUM(t.amount) AS total
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.full_name, a.account_type;

-- HOW TO READ THE PLAN:
-- Seq Scan       = full table scan (slow on large tables)
-- Index Scan     = uses an index (fast for selective queries)
-- Nested Loop    = for each row in outer, scan inner (fine for small)
-- Hash Join      = build hash table from smaller set, probe with larger
-- Cost=X..Y      = startup cost .. total cost (in arbitrary units)
-- Rows=N         = estimated rows returned
-- actual rows=N  = real rows (after ANALYZE)
-- Buffers        = pages read from disk vs cache


-- SECTION B: INDEXES

-- 5. Create a basic index on account_id in transactions
--    (most common lookup column)
CREATE INDEX IF NOT EXISTS idx_transactions_account_id
ON transactions(account_id);

-- 6. Create index on date column for range queries
CREATE INDEX IF NOT EXISTS idx_transactions_date
ON transactions(date);

-- 7. Composite index — useful when you always filter by both columns
CREATE INDEX IF NOT EXISTS idx_transactions_account_date
ON transactions(account_id, date);

-- 8. Run EXPLAIN again after indexes — notice change from Seq Scan to Index Scan
EXPLAIN ANALYZE
SELECT * FROM transactions WHERE account_id = 'A006';

-- 9. Check existing indexes on a table (Supabase/PostgreSQL)
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'transactions';

-- 10. Drop an index (cleanup)
DROP INDEX IF EXISTS idx_transactions_account_id;
DROP INDEX IF EXISTS idx_transactions_date;
DROP INDEX IF EXISTS idx_transactions_account_date;

-- KEY RULES TO REMEMBER:
-- ✅ Index columns used in WHERE, JOIN ON, ORDER BY
-- ✅ Index foreign keys (customer_id, account_id)
-- ✅ Composite index: put most selective column first
-- ❌ Don't index columns with very few distinct values (e.g. type with 6 values)
-- ❌ Indexes slow down INSERT/UPDATE/DELETE — trade-off on write-heavy tables
-- ❌ Too many indexes = bloated storage and slow writes


-- PRACTICE EXERCISES:
-- Ex 1: Run EXPLAIN ANALYZE on a query joining all 3 tables.
--       Note the join strategy used (Hash Join? Nested Loop?)
-- Ex 2: Create an index on customers.segment, run EXPLAIN on
--       SELECT * FROM customers WHERE segment = 'Premium' — any difference?
-- Ex 3: Research: what is a partial index? Write one that only indexes
--       transactions where type = 'Deposit'
