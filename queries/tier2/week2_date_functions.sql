-- ============================================================
-- WEEK 2: DATE / TIME FUNCTIONS
-- Tables used: transactions, accounts, customers
-- Concepts: DATE_TRUNC, EXTRACT, AGE, DATE_PART, intervals
-- Note: PostgreSQL syntax (Supabase)
-- ============================================================

-- 1. Extract year, month, day components from a date
SELECT
    date,
    EXTRACT(YEAR  FROM date::date) AS yr,
    EXTRACT(MONTH FROM date::date) AS mo,
    EXTRACT(DAY   FROM date::date) AS dy,
    TO_CHAR(date::date, 'Month')   AS month_name
FROM transactions
LIMIT 10;


-- 2. DATE_TRUNC: Group transactions by month
SELECT
    DATE_TRUNC('month', date::date) AS month,
    COUNT(*)                         AS tx_count,
    SUM(amount)                      AS total_amount
FROM transactions
GROUP BY DATE_TRUNC('month', date::date)
ORDER BY month;


-- 3. Filter: transactions in Q1 2024
SELECT *
FROM transactions
WHERE date::date BETWEEN '2024-01-01' AND '2024-03-31';


-- 4. Days since account was opened (account age)
SELECT
    account_id,
    account_type,
    open_date::date,
    CURRENT_DATE - open_date::date AS days_open,
    (CURRENT_DATE - open_date::date) / 365 AS years_open
FROM accounts
WHERE close_date IS NULL OR close_date = '';


-- 5. Monthly transaction summary with month label
SELECT
    TO_CHAR(date::date, 'YYYY-MM') AS month,
    type,
    COUNT(*)                        AS count,
    ROUND(SUM(amount)::numeric, 2)  AS total
FROM transactions
GROUP BY TO_CHAR(date::date, 'YYYY-MM'), type
ORDER BY month, type;


-- 6. How long has each customer been with the bank?
SELECT
    customer_id,
    full_name,
    join_date::date,
    AGE(CURRENT_DATE, join_date::date) AS tenure
FROM customers
ORDER BY join_date;


-- PRACTICE EXERCISES:
-- Ex 1: Show total deposits per quarter in 2024
-- Ex 2: Find accounts opened more than 5 years ago that are still active
-- Ex 3: Show the month with highest total withdrawal amount
