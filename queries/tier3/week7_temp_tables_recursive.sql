-- ============================================================
-- WEEK 7: TEMPORARY TABLES + RECURSIVE CTEs
-- Tables used: transactions, accounts
-- Concepts: Multi-step transformations, date spine generation
-- ============================================================

-- SECTION A: TEMPORARY TABLES
-- Use these to break complex analyses into readable steps

-- 1. Create a temp table of monthly account summaries
CREATE TEMP TABLE monthly_account_summary AS
SELECT
    account_id,
    DATE_TRUNC('month', date::date) AS month,
    COUNT(*)                         AS tx_count,
    SUM(amount)                      AS total_amount,
    AVG(amount)                      AS avg_amount,
    MAX(amount)                      AS max_amount
FROM transactions
GROUP BY account_id, DATE_TRUNC('month', date::date);

-- Now query from the temp table
SELECT * FROM monthly_account_summary ORDER BY account_id, month;

-- 2. Build on the temp table — find accounts with high activity months
SELECT
    account_id,
    month,
    tx_count,
    total_amount
FROM monthly_account_summary
WHERE tx_count >= 3
ORDER BY total_amount DESC;

-- Clean up
DROP TABLE IF EXISTS monthly_account_summary;


-- SECTION B: RECURSIVE CTEs
-- Classic use: generate a complete date series (date spine)

-- 3. Generate all dates in 2024 (date spine)
WITH RECURSIVE date_spine AS (
    SELECT '2024-01-01'::date AS dt          -- anchor
    UNION ALL
    SELECT dt + INTERVAL '1 day'             -- recursive step
    FROM date_spine
    WHERE dt < '2024-12-31'::date
)
SELECT dt FROM date_spine;

-- 4. Generate month spine for 2024
WITH RECURSIVE month_spine AS (
    SELECT DATE_TRUNC('month', '2024-01-01'::date) AS month
    UNION ALL
    SELECT month + INTERVAL '1 month'
    FROM month_spine
    WHERE month < '2024-12-01'::date
)
SELECT month FROM month_spine;

-- 5. KEY PATTERN: Left join actuals onto month spine
--    This fills in months with zero activity (no gaps in output)
WITH RECURSIVE month_spine AS (
    SELECT DATE_TRUNC('month', '2024-01-01'::date) AS month
    UNION ALL
    SELECT month + INTERVAL '1 month'
    FROM month_spine
    WHERE month < '2024-12-01'::date
),
monthly_actuals AS (
    SELECT
        DATE_TRUNC('month', date::date) AS month,
        SUM(amount)  AS total_amount,
        COUNT(*)     AS tx_count
    FROM transactions
    GROUP BY DATE_TRUNC('month', date::date)
)
SELECT
    TO_CHAR(s.month, 'YYYY-MM')             AS month,
    COALESCE(a.tx_count, 0)                 AS tx_count,
    COALESCE(ROUND(a.total_amount::numeric, 2), 0) AS total_amount
FROM month_spine s
LEFT JOIN monthly_actuals a ON s.month = a.month
ORDER BY s.month;

-- 6. Recursive CTE: Number hierarchy (simulate org tree or account tiers)
WITH RECURSIVE tier_levels AS (
    SELECT 1 AS level, 'Standard' AS tier, 0 AS min_balance
    UNION ALL
    SELECT level + 1,
           CASE level + 1 WHEN 2 THEN 'Premium' WHEN 3 THEN 'Corporate' END,
           level * 100000
    FROM tier_levels
    WHERE level < 3
)
SELECT * FROM tier_levels;


-- PRACTICE EXERCISES:
-- Ex 1: Generate a date spine for Jan-Jun 2024, join transactions onto it,
--       and show daily totals with 0 for days with no transactions
-- Ex 2: Using a temp table, first calculate each account's average monthly
--       spend, then in a second query find accounts above the overall average
-- Ex 3: Generate a weekly spine for Q1 2024 using recursive CTE
