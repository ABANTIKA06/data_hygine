-- =====================================================================
-- 🏦 Bank Customer Data Hygiene & Business Intelligence
-- Client / TUI: Harlequin (PostgreSQL)
-- Source Dataset: verification_cleared.csv (10,000 Clean Customer Records)
-- Story Reference: bi_insights_and_story_plan.md
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Table DDL Creation (PostgreSQL)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS bank_customers CASCADE;

CREATE TABLE bank_customers (
    customer_id      INT PRIMARY KEY,
    credit_score     INT NOT NULL CHECK (credit_score BETWEEN 300 AND 850),
    country          VARCHAR(50) NOT NULL,
    gender           VARCHAR(10) NOT NULL,
    age              INT NOT NULL CHECK (age >= 18),
    tenure           INT NOT NULL CHECK (tenure BETWEEN 0 AND 10),
    balance          NUMERIC(12, 2) NOT NULL CHECK (balance >= 0),
    products_number  INT NOT NULL CHECK (products_number BETWEEN 1 AND 4),
    credit_card      INT NOT NULL CHECK (credit_card IN (0, 1)),
    active_member    INT NOT NULL CHECK (active_member IN (0, 1))
);

-- Performance Indexes for analytical aggregations in Harlequin
CREATE INDEX idx_customers_country ON bank_customers(country);
CREATE INDEX idx_customers_balance ON bank_customers(balance);
CREATE INDEX idx_customers_active  ON bank_customers(active_member);
CREATE INDEX idx_customers_age     ON bank_customers(age);

-- ---------------------------------------------------------------------
-- 2. Data Ingestion
-- Run in Harlequin / psql:
-- ---------------------------------------------------------------------
COPY bank_customers 
FROM '/home/abantika/Documents/abantika_projects/data_hygine/verification_cleared.csv' 
WITH (FORMAT csv, HEADER true);


-- =====================================================================
-- 3. EXECUTIVE KPI DASHBOARD (The 30,000-ft Portfolio View)
-- Question: What are the foundational baseline metrics of the bank?
-- =====================================================================
SELECT 
    COUNT(*) AS total_customers,
    ROUND(SUM(balance), 2) AS total_deposits_aum,
    ROUND(AVG(balance), 2) AS overall_avg_balance,
    ROUND(AVG(balance) FILTER (WHERE balance > 0), 2) AS avg_funded_balance,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balance)::numeric, 2) AS median_balance,
    COUNT(*) FILTER (WHERE balance = 0) AS zero_balance_accounts,
    ROUND(COUNT(*) FILTER (WHERE balance = 0) * 100.0 / COUNT(*), 2) AS zero_balance_pct,
    COUNT(*) FILTER (WHERE active_member = 1) AS active_customers,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct,
    COUNT(*) FILTER (WHERE credit_card = 1) AS credit_card_holders,
    ROUND(AVG(credit_card) * 100.0, 2) AS credit_card_penetration_pct,
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    ROUND(AVG(age), 2) AS avg_age,
    ROUND(AVG(tenure), 2) AS avg_tenure_years
FROM bank_customers;


-- =====================================================================
-- 4. CHAPTER 1: THE BIMODAL DEPOSIT PARADOX (All-or-Nothing Balances)
-- Story: 34.1% have €0, 45.2% have >€100k, only 0.8% have €1-€50k.
-- =====================================================================
SELECT 
    CASE 
        WHEN balance = 0 THEN '1. Zero Balance (€0)'
        WHEN balance > 0 AND balance <= 50000 THEN '2. Low / Checking (€1 - €50k)'
        WHEN balance > 50000 AND balance <= 100000 THEN '3. Mid Savings (€50k - €100k)'
        WHEN balance > 100000 AND balance <= 150000 THEN '4. High Balance (€100k - €150k)'
        ELSE '5. Ultra High (>€150k)'
    END AS deposit_tier,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS customer_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(SUM(balance) * 100.0 / SUM(SUM(balance)) OVER(), 2) AS deposit_share_pct,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct,
    ROUND(AVG(credit_card) * 100.0, 2) AS credit_card_rate_pct
FROM bank_customers
GROUP BY 1
ORDER BY 1;


-- =====================================================================
-- 5. CHAPTER 2: THE TWO-PRODUCT CEILING (Cross-Sell Bottleneck)
-- Story: 96.8% locked at 1 or 2 products; 4-product holders hold 15% more deposits.
-- =====================================================================
SELECT 
    products_number AS number_of_products,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS customer_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct,
    ROUND(AVG(credit_card) * 100.0, 2) AS credit_card_hold_rate,
    ROUND(AVG(credit_score), 1) AS avg_credit_score
FROM bank_customers
GROUP BY products_number
ORDER BY products_number;


-- =====================================================================
-- 6. CHAPTER 3: THE €361M INACTIVITY HAZARD & SILENT CHURN RISK
-- Story: 4,711 inactive members hold €360.8M; 2,105 affluent accounts disengaged.
-- =====================================================================

-- Part A: Macro Active vs. Inactive Comparison
SELECT 
    CASE WHEN active_member = 1 THEN 'Active Customer' ELSE 'Inactive Customer' END AS activity_status,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS customer_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(SUM(balance) * 100.0 / SUM(SUM(balance)) OVER(), 2) AS deposit_share_pct,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(credit_card) * 100.0, 2) AS credit_card_rate_pct,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(AVG(age), 1) AS avg_age,
    ROUND(AVG(tenure), 1) AS avg_tenure_years
FROM bank_customers
GROUP BY active_member;

-- Part B: Affluent Inactive Accounts (High-Touch Retention Target)
SELECT 
    country,
    COUNT(*) AS inactive_affluent_count,
    ROUND(SUM(balance), 2) AS deposits_at_immediate_risk,
    ROUND(AVG(balance), 2) AS avg_inactive_balance,
    COUNT(*) FILTER (WHERE balance >= 150000) AS ultra_high_risk_gt_150k,
    ROUND(AVG(age), 1) AS avg_age
FROM bank_customers
WHERE active_member = 0 
  AND balance >= 100000
GROUP BY country
ORDER BY deposits_at_immediate_risk DESC;


-- =====================================================================
-- 7. CHAPTER 4: THE FLATLINING LOYALTY CURVE (Tenure vs. Value)
-- Story: Tenure does not compound balance or product adoption.
-- =====================================================================

-- Part A: Granular by Tenure Year (0 to 10)
SELECT 
    tenure AS tenure_years,
    COUNT(*) AS customer_count,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(products_number), 2) AS avg_products,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct,
    ROUND(AVG(credit_card) * 100.0, 2) AS credit_card_rate_pct
FROM bank_customers
GROUP BY tenure
ORDER BY tenure;

-- Part B: Grouped Tenure Cohorts
SELECT 
    CASE 
        WHEN tenure BETWEEN 0 AND 2 THEN '1. New (0-2 Years)'
        WHEN tenure BETWEEN 3 AND 6 THEN '2. Established (3-6 Years)'
        ELSE '3. Mature / Loyal (7-10 Years)'
    END AS tenure_cohort,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS customer_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(products_number), 2) AS avg_products,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct
FROM bank_customers
GROUP BY 1
ORDER BY 1;


-- =====================================================================
-- 8. CHAPTER 5: GEOGRAPHIC ECONOMICS (Volume vs. Wealth vs. Dormancy)
-- Story: France = Scale; Germany = Wealth Density; Spain = High Dormancy.
-- =====================================================================
SELECT 
    country,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS customer_share_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(SUM(balance) * 100.0 / SUM(SUM(balance)) OVER(), 2) AS deposit_share_pct,
    ROUND(AVG(balance), 2) AS overall_avg_balance,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balance)::numeric, 2) AS median_balance,
    COUNT(*) FILTER (WHERE balance > 0) AS funded_customers,
    ROUND(AVG(balance) FILTER (WHERE balance > 0), 2) AS avg_funded_balance,
    COUNT(*) FILTER (WHERE balance = 0) AS zero_balance_count,
    ROUND(COUNT(*) FILTER (WHERE balance = 0) * 100.0 / COUNT(*), 2) AS zero_balance_pct,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct
FROM bank_customers
GROUP BY country
ORDER BY total_deposits DESC;


-- =====================================================================
-- 9. STRATEGIC CUSTOMER PERSONAS (Commercial Segmentation)
-- Story: Actionable playbooks for 4 targeted business segments.
-- =====================================================================
WITH customer_classification AS (
    SELECT 
        customer_id,
        country,
        balance,
        active_member,
        credit_score,
        products_number,
        CASE 
            WHEN balance = 0 AND credit_card = 1 
                THEN '1. Dormant Cardholder (€0 Bal + Credit Card)'
            WHEN balance >= 100000 AND active_member = 0 
                THEN '2. Silent VIP / At-Risk Wealth (Bal >= €100k + Inactive)'
            WHEN age BETWEEN 30 AND 45 AND balance BETWEEN 50000 AND 150000 AND active_member = 1 
                THEN '3. Core Family Builder (Age 30-45, €50k-€150k, Active)'
            WHEN balance >= 50000 AND credit_score < 670 
                THEN '4. Credit-Constrained Depositor (Bal >= €50k, Score < 670)'
            ELSE '5. General Portfolio / Other'
        END AS strategic_persona
    FROM bank_customers
)
SELECT 
    strategic_persona,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_customers), 2) AS pct_of_base,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(SUM(balance) * 100.0 / (SELECT SUM(balance) FROM bank_customers), 2) AS pct_of_total_deposits,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(AVG(products_number), 2) AS avg_products
FROM customer_classification
GROUP BY strategic_persona
ORDER BY strategic_persona;


-- =====================================================================
-- 10. CREDIT RISK & LENDING OPPORTUNITY PORTFOLIO
-- Story: 59.3% have credit score < 670 despite holding €75k+ balances.
-- =====================================================================
SELECT 
    CASE 
        WHEN credit_score >= 800 THEN 'Tier 1: Exceptional (800-850)'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Tier 2: Very Good (740-799)'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Tier 3: Good (670-739)'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Tier 4: Fair (580-669)'
        ELSE 'Tier 5: Poor (<580)'
    END AS credit_tier,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS portfolio_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(active_member) * 100.0, 2) AS active_rate_pct,
    ROUND(AVG(credit_card) * 100.0, 2) AS credit_card_rate_pct
FROM bank_customers
GROUP BY 1
ORDER BY MIN(credit_score) DESC;


-- =====================================================================
-- 11. WEALTH CONCENTRATION: TOP 10% VIP DECILE ANALYSIS
-- Story: Top 10% hold 21.3% of bank deposits (€164.7M); 45.8% are inactive.
-- =====================================================================
WITH ranked_customers AS (
    SELECT 
        *,
        NTILE(10) OVER (ORDER BY balance DESC) AS wealth_decile
    FROM bank_customers
)
SELECT 
    CASE WHEN wealth_decile = 1 THEN 'Top 10% Wealthiest (Decile 1)' ELSE 'Remaining 90% Customers' END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(MIN(balance), 2) AS min_balance,
    ROUND(MAX(balance), 2) AS max_balance,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(SUM(balance) * 100.0 / (SELECT SUM(balance) FROM bank_customers), 2) AS pct_of_all_bank_deposits,
    ROUND(AVG(active_member) * 100.0, 2) AS active_pct
FROM ranked_customers
GROUP BY 1
ORDER BY avg_balance DESC;


-- =====================================================================
-- 12. LIFE STAGE COHORT ANALYSIS (Demographics & Age)
-- Story: Ages 30-45 generate 64.1% of deposits; Seniors 60+ show activity drop.
-- =====================================================================
WITH age_segments AS (
    SELECT 
        customer_id,
        balance,
        active_member,
        credit_score,
        products_number,
        CASE 
            WHEN age < 30 THEN '1. Young Adults (<30)'
            WHEN age BETWEEN 30 AND 45 THEN '2. Early Career / Families (30-45)'
            WHEN age BETWEEN 46 AND 60 THEN '3. Peak Earners (46-60)'
            ELSE '4. Seniors & Retirees (60+)'
        END AS life_stage
    FROM bank_customers
)
SELECT 
    life_stage,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS cohort_pct,
    ROUND(SUM(balance), 2) AS total_deposits,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balance)::numeric, 2) AS median_balance,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(AVG(active_member) * 100.0, 2) AS active_pct,
    ROUND(AVG(products_number), 2) AS avg_products
FROM age_segments
GROUP BY life_stage
ORDER BY life_stage;
