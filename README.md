# SQL Practice — MSc Business Analytics (BI Norwegian)

A 10-week SQL study plan covering Tier 2 and Tier 3 analytics SQL,
built on a mock banking dataset aligned with real ALM/treasury work.

## Repository Structure

```
sql-practice/
├── data/
│   ├── customers.csv       # 15 customers (BD + Norway)
│   ├── accounts.csv        # 17 accounts across types
│   ├── transactions.csv    # 180 transactions across 2024
│   └── products.csv        # 10 banking products
│
├── queries/
│   ├── tier2/
│   │   ├── week1_lag_lead.sql
│   │   ├── week2_date_functions.sql
│   │   ├── week3_running_totals.sql
│   │   ├── week4_pivot_conditional.sql
│   │   └── week5_cleaning.sql
│   ├── tier3/
│   │   ├── week6_exists_selfjoins.sql
│   │   ├── week7_temp_tables_recursive.sql
│   │   ├── week8_explain_indexes.sql
│   │   └── week9_json_functions.sql
│   └── week10_capstone.sql
└── README.md
```

## Study Schedule

| Week | Topic | Tier |
|------|-------|------|
| 1 | LAG / LEAD | 2 |
| 2 | Date / Time Functions | 2 |
| 3 | Running Sums & Moving Averages | 2 |
| 4 | PIVOT via Conditional Aggregation | 2 |
| 5 | CAST, String Functions, UNION | 2 |
| 6 | EXISTS / NOT EXISTS + Self-JOINs | 3 |
| 7 | Temporary Tables + Recursive CTEs | 3 |
| 8 | EXPLAIN + Indexes | 3 |
| 9 | JSON Functions | 3 |
| 10 | Capstone — End-to-End Dashboard Query | Both |

## Setup

### Supabase
1. Create account at [supabase.com](https://supabase.com)
2. New project → name it `sql-practice`
3. Table Editor → Import CSV for each file in `/data`
4. SQL Editor → paste and run queries from `/queries`

### Running Queries
All queries are written in **PostgreSQL dialect** (Supabase native).
No extensions required. Run each file top-to-bottom in Supabase SQL Editor.

## Data Model

```
customers ──< accounts ──< transactions
products (standalone reference table)
```

- `customers.customer_id` → `accounts.customer_id`
- `accounts.account_id`   → `transactions.account_id`

---
*Target: BI Norwegian MSc Business Analytics, starting August 2026*
