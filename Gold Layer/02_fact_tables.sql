-- =============================================================================
-- CREATE FACT TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 fact_study_sessions (PRIMARY FACT TABLE)
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.fact_study_sessions (
    session_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES analytics.dim_user(user_id),
    set_id INTEGER NOT NULL REFERENCES analytics.dim_set(set_id),
    date_id INTEGER NOT NULL REFERENCES analytics.dim_date(date_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    duration_sec INTEGER NOT NULL,
    cards_studied INTEGER NOT NULL,
    subscription_plan_at_time VARCHAR(20) NOT NULL
);

-- Populate fact_study_sessions
INSERT INTO analytics.fact_study_sessions (
    session_id, user_id, set_id, date_id, start_time, 
    end_time, duration_sec, cards_studied, subscription_plan_at_time
)
SELECT 
    s.session_id,
    s.user_id,
    s.set_id,
    TO_CHAR(s.start_time::DATE, 'YYYYMMDD')::INTEGER AS date_id,
    s.start_time,
    s.end_time,
    s.duration_sec,
    s.cards_studied,
    COALESCE(
        (SELECT sub.plan 
         FROM public.subscriptions sub 
         WHERE sub.user_id = s.user_id 
           AND s.start_time::DATE >= sub.start_date 
           AND (s.start_time::DATE <= sub.end_date OR sub.end_date IS NULL)
         ORDER BY sub.start_date DESC 
         LIMIT 1),
        'free'
    ) AS subscription_plan_at_time
FROM public.study_sessions s;

-- -----------------------------------------------------------------------------
-- 3.2 fact_subscriptions
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.fact_subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES analytics.dim_user(user_id),
    plan_id INTEGER NOT NULL REFERENCES analytics.dim_subscription_plan(plan_id),
    start_date_id INTEGER NOT NULL REFERENCES analytics.dim_date(date_id),
    end_date_id INTEGER REFERENCES analytics.dim_date(date_id),
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    duration_days INTEGER
);

-- Populate fact_subscriptions
INSERT INTO analytics.fact_subscriptions (
    subscription_id, user_id, plan_id, start_date_id, end_date_id, 
    price, status, duration_days
)
SELECT 
    sub.subscription_id,
    sub.user_id,
    p.plan_id,
    TO_CHAR(sub.start_date, 'YYYYMMDD')::INTEGER AS start_date_id,
    TO_CHAR(sub.end_date, 'YYYYMMDD')::INTEGER AS end_date_id,
    sub.price,
    sub.status,
    CASE 
        WHEN sub.end_date IS NOT NULL 
        THEN (sub.end_date - sub.start_date)::INTEGER
        ELSE NULL
    END AS duration_days
FROM public.subscriptions sub
JOIN analytics.dim_subscription_plan p ON sub.plan = p.plan_name;

-- -----------------------------------------------------------------------------
-- 3.3 fact_set_creation
-- -----------------------------------------------------------------------------

CREATE TABLE analytics.fact_set_creation (
    set_id INTEGER PRIMARY KEY REFERENCES analytics.dim_set(set_id),
    user_id INTEGER NOT NULL REFERENCES analytics.dim_user(user_id),
    date_id INTEGER NOT NULL REFERENCES analytics.dim_date(date_id),
    card_count INTEGER NOT NULL,
    topic VARCHAR(50) NOT NULL
);

-- Populate fact_set_creation
INSERT INTO analytics.fact_set_creation (
    set_id, user_id, date_id, card_count, topic
)
SELECT 
    s.set_id,
    s.owner_user_id,
    TO_CHAR(s.creation_date, 'YYYYMMDD')::INTEGER AS date_id,
    s.card_count,
    s.topic
FROM public.sets s;
