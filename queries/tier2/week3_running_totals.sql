-- ============================================================
-- WEEK 3: RUNNING SUMS & MOVING AVERAGES
-- Tables used: transactions
-- Concepts: Window frames, ROWS BETWEEN, cumulative and rolling calc
-- ============================================================

-- 1. Running total of all transactions (ordered by date)
SELECT
    transaction_id,
    date,
    amount,
    SUM(amount) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM transactions
ORDER BY date;


-- 2. Running total per account (reset per account)
SELECT
    transaction_id,
    account_id,
    date,
    amount,
    SUM(amount) OVER (
        PARTITION BY account_id
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS account_running_total
FROM transactions
ORDER BY account_id, date;


-- 3. 3-transaction moving average (per account)
SELECT
    transaction_id,
    account_id,
    date,
    amount,
    ROUND(
        AVG(amount) OVER (
            PARTITION BY account_id
            ORDER BY date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 2
    ) AS moving_avg_3tx
FROM transactions
ORDER BY account_id, date;


-- 4. Monthly totals with running monthly cumulative
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', date::date) AS month,
        SUM(amount) AS monthly_total
    FROM transactions
    GROUP BY DATE_TRUNC('month', date::date)
)
SELECT
    month,
    monthly_total,
    SUM(monthly_total) OVER (ORDER BY month) AS cumulative_total
FROM monthly
ORDER BY month;


-- 5. 3-month rolling average on monthly totals
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', date::date) AS month,
        SUM(amount) AS monthly_total
    FROM transactions
    GROUP BY DATE_TRUNC('month', date::date)
)
SELECT
    month,
    monthly_total,
    ROUND(
        AVG(monthly_total) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 2
    ) AS rolling_3m_avg
FROM monthly
ORDER BY month;


-- PRACTICE EXERCISES:
-- Ex 1: Running count of transactions per account (how many so far at each row)
-- Ex 2: 7-transaction moving sum for account A006
-- Ex 3: Show cumulative deposits only (filter type = 'Deposit' before windowing)
