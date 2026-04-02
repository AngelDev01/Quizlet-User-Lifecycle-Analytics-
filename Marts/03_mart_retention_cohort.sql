-- =============================================================================
-- M2.3: Cohort Retention Comparison
-- =============================================================================

WITH cohorts AS (
    -- Define cohorts by signup week/year
    SELECT
        u.user_id,
        d.year AS cohort_year,
        d.week_number AS signup_week,
        d.date AS signup_date
    FROM analytics.dim_user u
    JOIN analytics.dim_date d
        ON u.signup_date_id = d.date_id
),

-- Calculate TRUE cohort size from all signups
cohort_sizes AS (
    SELECT
        cohort_year,
        signup_week,
        COUNT(DISTINCT user_id) AS true_cohort_size
    FROM cohorts
    GROUP BY cohort_year, signup_week
),

activity AS (
    -- Join study sessions to cohorts and compute days since signup
    SELECT
        c.user_id,
        c.cohort_year,
        c.signup_week,
        c.signup_date,
        fss.start_time::date AS activity_date,
        (fss.start_time::date - c.signup_date) AS days_since_signup
    FROM cohorts c
    JOIN analytics.fact_study_sessions fss
        USING(user_id)
),

retention_summary AS (
    -- Aggregate retained users per cohort per day
    SELECT
        cohort_year,
        signup_week,
        days_since_signup,
        COUNT(DISTINCT user_id) AS cohort_retained
    FROM activity
    -- WHERE days_since_signup IN (0, 7, 14, 30)
    GROUP BY cohort_year, signup_week, days_since_signup
)

-- Final output with cohort size
SELECT
    r.signup_week,
    r.days_since_signup,
    r.cohort_retained,
    cs.true_cohort_size AS cohort_size,
    ROUND(
        r.cohort_retained::numeric / cs.true_cohort_size * 100, 2
    ) AS pct_retained
FROM retention_summary r
JOIN cohort_sizes cs 
    ON r.cohort_year = cs.cohort_year 
    AND r.signup_week = cs.signup_week
ORDER BY r.signup_week, r.days_since_signup;
