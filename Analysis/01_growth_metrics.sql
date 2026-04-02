-- =============================================================================
-- M0.1: Weekly Active Learners (WAL) - Week-over-Week Growth
-- Description:
--   Calculate the number of distinct users who studied per week (WAL) and the
--   percentage change vs. the previous week.
-- =============================================================================
WITH weekly_wal AS (
    -- Step 1: Aggregate weekly WAL
    SELECT
        d.year,                                -- Needed to correctly group by year + week
        d.week_number AS week,                 -- week ISO number
        COUNT(DISTINCT fss.user_id) AS wal     -- Weekly Active Learners (distinct users per week)
    FROM analytics.fact_study_sessions fss
    JOIN analytics.dim_date d
        USING(date_id)                          -- Use date dimension to simplify time calculations
    GROUP BY d.year, d.week_number
),

wal_with_lag AS (
    -- Step 2: Compute previous week's WAL using window function
    SELECT
        week,
        wal,
        LAG(wal) OVER (ORDER BY week ASC) AS prev_wal  -- Previous week's WAL
    FROM weekly_wal
),

wal_growth AS (
    -- Step 3: Compute week-over-week growth
    SELECT
        week,
        wal,
        prev_wal,
        ROUND((wal::numeric / NULLIF(prev_wal,0) - 1) * 100, 1) AS wow_growth_pct  -- WoW % change
    FROM wal_with_lag
)

-- Final output
SELECT
    week AS week_number,       -- week ISO number
    wal AS weekly_active_learners, 
    prev_wal AS previous_week_wal,
    wow_growth_pct AS pct_change_wow
FROM wal_growth
ORDER BY week ASC;


-- =============================================================================
-- M0.2: Weekly Active Learners (WAL) Trend
-- Description:
--   Provides the number of distinct users who studied per week.
--   This is used for line charts showing WAL trend over time.
-- =============================================================================
WITH weekly_wal AS (
    -- Step 1: Aggregate weekly WAL
    SELECT
        d.year,                                -- Used for grouping to avoid week collisions across years
        d.week_number AS week,                 -- week number
        COUNT(DISTINCT fss.user_id) AS wal     -- Weekly Active Learners (distinct users per week)
    FROM analytics.fact_study_sessions fss
    JOIN analytics.dim_date d
        USING(date_id)                          -- Use date dimension to simplify time calculations
    GROUP BY d.year, d.week_number
)

-- Final output
SELECT
    week AS week_number,                       -- week ISO number
    wal AS weekly_active_learners
FROM weekly_wal
ORDER BY week ASC;


-- =============================================================================
-- M0.3: New vs Returning Users Contribution
-- Description:
--   For each week, calculate how many Weekly Active Learners (WAL) are
--   new users versus returning users, along with their percentage contribution.
-- =============================================================================
WITH user_first_activity AS (
    -- Step 1: Get the first session date for each user
    SELECT
        user_id,
        MIN(start_time::date) AS first_session_date
    FROM analytics.fact_study_sessions
    GROUP BY user_id
),

weekly_user_type AS (
    -- Step 2: Classify weekly sessions as new or returning
    SELECT
        date_trunc('week', fss.start_time)::date AS week_start,  -- ISO week start (Monday)
        COUNT(DISTINCT CASE 
            WHEN date_trunc('week', ufa.first_session_date) = date_trunc('week', fss.start_time)
            THEN fss.user_id 
        END) AS new_users,
        COUNT(DISTINCT CASE 
            WHEN date_trunc('week', ufa.first_session_date) < date_trunc('week', fss.start_time)
            THEN fss.user_id 
        END) AS returning_users
    FROM analytics.fact_study_sessions fss
    JOIN user_first_activity ufa
        USING(user_id)
    GROUP BY week_start
),

weekly_user_contribution AS (
    -- Step 3: Add total WAL and percentage contribution
    SELECT
        week_start,
        new_users,
        returning_users,
        new_users + returning_users AS total_wal,
        ROUND(new_users::numeric / (new_users + returning_users) * 100, 1) AS pct_new_users,
        ROUND(returning_users::numeric / (new_users + returning_users) * 100, 1) AS pct_returning_users
    FROM weekly_user_type
)

-- Final output for dashboards or reports
SELECT
    week_start,
    new_users,
    returning_users,
    total_wal,
    pct_new_users,
    pct_returning_users
FROM weekly_user_contribution
ORDER BY week_start ASC;


-- =============================================================================
-- M0.4 WAL by Signup Cohort
-- For each signup cohort (users grouped by signup week),
-- compute how many of those users were active in each subsequent week.
-- =============================================================================
WITH cohort_activity AS (
  SELECT
    d_signup.year AS signup_year,
    d_signup.week_number AS signup_week,
    d_activity.year AS activity_year,
    d_activity.week_number AS activity_week,
    COUNT(DISTINCT fss.user_id) AS wal  -- weekly active learners from this cohort
  FROM analytics.fact_study_sessions fss
  JOIN analytics.dim_user u
    USING (user_id)
  JOIN analytics.dim_date d_activity
    ON fss.date_id = d_activity.date_id
  JOIN analytics.dim_date d_signup
    ON u.signup_date_id = d_signup.date_id
  -- ensure activity happens in or after the signup week
  WHERE (d_activity.year, d_activity.week_number) >= (d_signup.year, d_signup.week_number)
  GROUP BY
    d_signup.year,
    d_signup.week_number,
    d_activity.year,
    d_activity.week_number
)

SELECT
  signup_year,
  signup_week,
  activity_year,
  activity_week,
  wal
FROM cohort_activity
ORDER BY
  signup_year,
  signup_week,
  activity_year,
  activity_week;
