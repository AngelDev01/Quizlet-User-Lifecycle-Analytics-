-- =============================================================================
-- CREATE ANALYTICS SCHEMA
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS analytics;


-- =============================================================================
-- CREATE DIMENSION TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.1 dim_date (Generated calendar table)
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.dim_date (
    date_id INTEGER PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    week_number INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INTEGER NOT NULL,
    year INTEGER NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_month_start BOOLEAN NOT NULL,
    is_month_end BOOLEAN NOT NULL
);

-- Populate dim_date (March 1 - April 30, 2026)
INSERT INTO analytics.dim_date (
    date_id, date, day_of_week, day_name, week_number, 
    month, month_name, quarter, year, is_weekend, 
    is_month_start, is_month_end
)
SELECT 
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_id,
    d AS date,
    EXTRACT(DOW FROM d)::INTEGER AS day_of_week,
    TO_CHAR(d, 'Day') AS day_name,
    EXTRACT(WEEK FROM d)::INTEGER AS week_number,
    EXTRACT(MONTH FROM d)::INTEGER AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    EXTRACT(YEAR FROM d)::INTEGER AS year,
    (EXTRACT(DOW FROM d) IN (0, 6)) AS is_weekend,
    (EXTRACT(DAY FROM d) = 1) AS is_month_start,
    (d = (DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::DATE) AS is_month_end
FROM GENERATE_SERIES('2026-03-01'::DATE, '2026-04-30'::DATE, '1 day'::INTERVAL) AS d;

-- -----------------------------------------------------------------------------
-- 2.2 dim_user
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.dim_user (
    user_id INTEGER PRIMARY KEY,
    signup_date DATE NOT NULL,
    signup_date_id INTEGER REFERENCES analytics.dim_date(date_id),
    country VARCHAR(100),
    age_group VARCHAR(20) NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL,
    activation_status VARCHAR(20) NOT NULL,
    is_premium BOOLEAN NOT NULL,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Populate dim_user
INSERT INTO analytics.dim_user (
    user_id, signup_date, signup_date_id, country, age_group, 
    acquisition_channel, activation_status, is_premium
)
SELECT 
    u.user_id,
    u.signup_date,
    TO_CHAR(u.signup_date, 'YYYYMMDD')::INTEGER AS signup_date_id,
    u.country,
    u.age_group,
    u.acquisition_channel,
    CASE 
        WHEN EXISTS (SELECT 1 FROM public.study_sessions s WHERE s.user_id = u.user_id) 
        THEN 'Active' 
        ELSE 'Inactive' 
    END AS activation_status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.subscriptions sub 
            WHERE sub.user_id = u.user_id AND sub.plan = 'premium'
        ) 
        THEN TRUE 
        ELSE FALSE 
    END AS is_premium
FROM public.users u;

-- -----------------------------------------------------------------------------
-- 2.3 dim_set
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.dim_set (
    set_id INTEGER PRIMARY KEY,
    owner_user_id INTEGER REFERENCES analytics.dim_user(user_id),
    topic VARCHAR(50) NOT NULL,
    card_count INTEGER NOT NULL,
    creation_date DATE NOT NULL,
    creation_date_id INTEGER REFERENCES analytics.dim_date(date_id),
    visibility VARCHAR(20) DEFAULT 'public'
);

-- Populate dim_set
INSERT INTO analytics.dim_set (
    set_id, owner_user_id, topic, card_count, creation_date, 
    creation_date_id, visibility
)
SELECT 
    s.set_id,
    s.owner_user_id,
    s.topic,
    s.card_count,
    s.creation_date,
    TO_CHAR(s.creation_date, 'YYYYMMDD')::INTEGER AS creation_date_id,
    'public' AS visibility
FROM public.sets s;

-- -----------------------------------------------------------------------------
-- 2.4 dim_subscription_plan
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.dim_subscription_plan (
    plan_id INTEGER PRIMARY KEY,
    plan_name VARCHAR(20) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);

-- Populate dim_subscription_plan
INSERT INTO analytics.dim_subscription_plan (
    plan_id, plan_name, price, billing_cycle, description
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY plan) AS plan_id,
    plan AS plan_name,
    COALESCE(AVG(price), 0) AS price,
    'monthly' AS billing_cycle,
    CASE plan
        WHEN 'free' THEN 'Free tier with basic features'
        WHEN 'trial' THEN '14-day free trial'
        WHEN 'premium' THEN 'Full access to all features'
    END AS description
FROM public.subscriptions
GROUP BY plan;
