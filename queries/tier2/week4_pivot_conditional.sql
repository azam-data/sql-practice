-- ============================================================
-- WEEK 4: PIVOT via CONDITIONAL AGGREGATION
-- Tables used: transactions
-- Concepts: SUM(CASE WHEN), COUNT(CASE WHEN), wide format output
-- Note: PostgreSQL has no native PIVOT — this approach works everywhere
-- ============================================================

-- 1. Count of transactions by type per account (wide format)
SELECT
    account_id,
    COUNT(CASE WHEN type = 'Deposit'       THEN 1 END) AS deposits,
    COUNT(CASE WHEN type = 'Withdrawal'    THEN 1 END) AS withdrawals,
    COUNT(CASE WHEN type = 'Transfer'      THEN 1 END) AS transfers,
    COUNT(CASE WHEN type = 'Fee'           THEN 1 END) AS fees,
    COUNT(CASE WHEN type = 'Interest'      THEN 1 END) AS interest_credits,
    COUNT(CASE WHEN type = 'Loan Repayment' THEN 1 END) AS loan_repayments
FROM transactions
GROUP BY account_id
ORDER BY account_id;


-- 2. Total amount by type per account
SELECT
    account_id,
    ROUND(SUM(CASE WHEN type = 'Deposit'    THEN amount ELSE 0 END)::numeric, 2) AS total_deposits,
    ROUND(SUM(CASE WHEN type = 'Withdrawal' THEN amount ELSE 0 END)::numeric, 2) AS total_withdrawals,
    ROUND(SUM(CASE WHEN type = 'Transfer'   THEN amount ELSE 0 END)::numeric, 2) AS total_transfers,
    ROUND(SUM(CASE WHEN type = 'Fee'        THEN amount ELSE 0 END)::numeric, 2) AS total_fees
FROM transactions
GROUP BY account_id
ORDER BY account_id;


-- 3. Monthly breakdown: rows = months, columns = transaction types
SELECT
    TO_CHAR(date::date, 'YYYY-MM')                                                  AS month,
    ROUND(SUM(CASE WHEN type = 'Deposit'    THEN amount ELSE 0 END)::numeric, 2)    AS deposits,
    ROUND(SUM(CASE WHEN type = 'Withdrawal' THEN amount ELSE 0 END)::numeric, 2)    AS withdrawals,
    ROUND(SUM(CASE WHEN type = 'Transfer'   THEN amount ELSE 0 END)::numeric, 2)    AS transfers,
    ROUND(SUM(CASE WHEN type = 'Interest'   THEN amount ELSE 0 END)::numeric, 2)    AS interest
FROM transactions
GROUP BY TO_CHAR(date::date, 'YYYY-MM')
ORDER BY month;


-- 4. Customer segment pivot from accounts + customers
SELECT
    a.account_type,
    COUNT(CASE WHEN c.segment = 'Standard'  THEN 1 END) AS standard_count,
    COUNT(CASE WHEN c.segment = 'Premium'   THEN 1 END) AS premium_count,
    COUNT(CASE WHEN c.segment = 'Corporate' THEN 1 END) AS corporate_count
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.close_date IS NULL OR a.close_date = ''
GROUP BY a.account_type;


-- PRACTICE EXERCISES:
-- Ex 1: Create a pivot showing average transaction amount per type per account
-- Ex 2: Show quarterly deposit vs withdrawal totals side by side
-- Ex 3: Flag accounts where total fees exceed 1000 (use HAVING on conditional sum)
