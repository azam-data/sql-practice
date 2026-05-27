-- ============================================================
-- WEEK 10: CAPSTONE — End-to-End Banking Analytics Query
-- This single script combines concepts from Weeks 1-9
-- Tables: transactions, accounts, customers
-- Goal: Produce a monthly management dashboard output
-- ============================================================

-- STEP 1: Month spine (no gaps in output)
WITH RECURSIVE month_spine AS (
    SELECT DATE_TRUNC('month', MIN(date::date)) AS month
    FROM transactions
    UNION ALL
    SELECT month + INTERVAL '1 month'
    FROM month_spine
    WHERE month < (SELECT DATE_TRUNC('month', MAX(date::date)) FROM transactions)
),

-- STEP 2: Monthly transaction summary (pivot by type)
monthly_txn AS (
    SELECT
        DATE_TRUNC('month', date::date) AS month,
        account_id,
        COUNT(*)                                                                      AS tx_count,
        ROUND(SUM(CASE WHEN type = 'Deposit'    THEN amount ELSE 0 END)::numeric, 2) AS deposits,
        ROUND(SUM(CASE WHEN type = 'Withdrawal' THEN amount ELSE 0 END)::numeric, 2) AS withdrawals,
        ROUND(SUM(CASE WHEN type = 'Fee'        THEN amount ELSE 0 END)::numeric, 2) AS fees,
        ROUND(SUM(CASE WHEN type = 'Interest'   THEN amount ELSE 0 END)::numeric, 2) AS interest
    FROM transactions
    GROUP BY DATE_TRUNC('month', date::date), account_id
),

-- STEP 3: Aggregate to portfolio level (all accounts)
monthly_portfolio AS (
    SELECT
        month,
        SUM(tx_count)    AS total_txns,
        SUM(deposits)    AS total_deposits,
        SUM(withdrawals) AS total_withdrawals,
        SUM(fees)        AS total_fees,
        SUM(interest)    AS total_interest,
        SUM(deposits) - SUM(withdrawals) AS net_flow
    FROM monthly_txn
    GROUP BY month
),

-- STEP 4: Join spine to actuals (fill gaps), add running totals + MoM change
final AS (
    SELECT
        TO_CHAR(s.month, 'YYYY-MM')                          AS month,
        COALESCE(p.total_txns, 0)                            AS transactions,
        COALESCE(p.total_deposits, 0)                        AS deposits,
        COALESCE(p.total_withdrawals, 0)                     AS withdrawals,
        COALESCE(p.total_fees, 0)                            AS fees,
        COALESCE(p.net_flow, 0)                              AS net_flow,

        -- Running cumulative deposits
        SUM(COALESCE(p.total_deposits, 0)) OVER (ORDER BY s.month) AS cumulative_deposits,

        -- MoM deposit change
        COALESCE(p.total_deposits, 0) -
        LAG(COALESCE(p.total_deposits, 0)) OVER (ORDER BY s.month) AS deposit_mom_change,

        -- 3-month rolling average of net flow
        ROUND(
            AVG(COALESCE(p.net_flow, 0)) OVER (
                ORDER BY s.month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            )::numeric, 2
        ) AS net_flow_3m_avg,

        -- Rank months by deposit volume
        RANK() OVER (ORDER BY COALESCE(p.total_deposits, 0) DESC) AS deposit_rank
    FROM month_spine s
    LEFT JOIN monthly_portfolio p ON s.month = p.month
)

-- FINAL OUTPUT: Management dashboard
SELECT
    month,
    transactions,
    deposits,
    withdrawals,
    fees,
    net_flow,
    cumulative_deposits,
    deposit_mom_change,
    net_flow_3m_avg,
    deposit_rank,
    CASE
        WHEN deposit_mom_change > 0 THEN '↑ Growth'
        WHEN deposit_mom_change < 0 THEN '↓ Decline'
        WHEN deposit_mom_change = 0 THEN '→ Flat'
        ELSE 'First Month'
    END AS trend_label
FROM final
ORDER BY month;


-- ============================================================
-- BONUS: Top 3 accounts by total deposit volume
-- ============================================================
SELECT
    a.account_id,
    a.account_type,
    c.full_name,
    c.segment,
    ROUND(SUM(t.amount)::numeric, 2) AS total_deposits,
    COUNT(t.transaction_id)          AS deposit_count,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS deposit_rank
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.type = 'Deposit'
GROUP BY a.account_id, a.account_type, c.full_name, c.segment
ORDER BY total_deposits DESC
LIMIT 3;
