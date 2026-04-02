-- ==========================================
-- M3.1: DAU/MAU Ratio (Daily Stickiness)
-- Shows daily active users divided by monthly active users
-- ==========================================
WITH daily_active_users AS (
    -- Count distinct users per day
    SELECT
        fss.start_time::date AS activity_date,
        COUNT(DISTINCT fss.user_id) AS dau
    FROM analytics.fact_study_sessions fss
    GROUP BY activity_date
),

monthly_active_users AS (
    -- Count distinct users per month
    SELECT
        date_trunc('month', fss.start_time)::date AS month_start,
        COUNT(DISTINCT fss.user_id) AS mau
    FROM analytics.fact_study_sessions fss
    GROUP BY month_start
)

SELECT
    dau.activity_date,
    dau.dau,
    mau.mau,
    -- DAU / MAU ratio (%), safe division
    ROUND(dau.dau::numeric / NULLIF(mau.mau, 0) * 100, 2) AS dau_mau_percent
FROM daily_active_users dau
JOIN monthly_active_users mau
    ON date_trunc('month', dau.activity_date) = mau.month_start
ORDER BY dau.activity_date;


-- ==========================================
-- M3.2: Sessions per User per Week
-- Measures average number of study sessions per user per week
-- ==========================================
WITH sessions_per_week AS (
    -- Count sessions per user per week
    SELECT
        d.year AS session_year,
        d.week_number AS session_week,
        fss.user_id,
        COUNT(fss.session_id) AS sessions_this_week
    FROM analytics.fact_study_sessions fss
    JOIN analytics.dim_date d
        USING(date_id)
    GROUP BY session_year, session_week, fss.user_id
)

SELECT
    session_year,
    session_week,
    user_id,
    sessions_this_week,
    -- Average sessions per user in that week (all users)
    ROUND(AVG(sessions_this_week) OVER (PARTITION BY session_year, session_week), 2) AS avg_sessions_per_user
FROM sessions_per_week
ORDER BY session_year, session_week, user_id;


-- ==========================================
-- M3.3: Average Session Duration
-- Measures how long users spend per session on average
-- Aggregated weekly per user and overall
-- ==========================================
WITH session_durations AS (
    -- Compute total duration and session count per user per week
    SELECT
        d.year AS session_year,
        d.week_number AS session_week,
        fss.user_id,
        COUNT(fss.session_id) AS sessions_this_week,
        SUM(fss.duration_sec) AS total_duration_sec
    FROM analytics.fact_study_sessions fss
    JOIN analytics.dim_date d
        USING(date_id)
    GROUP BY session_year, session_week, fss.user_id
)

SELECT
    session_year,
    session_week,
    user_id,
    sessions_this_week,
    total_duration_sec,
    -- Average session duration per user in seconds
    ROUND(total_duration_sec::numeric / NULLIF(sessions_this_week,0), 2) AS avg_session_duration_sec,
    -- Average session duration across all users in the week
    ROUND(AVG(total_duration_sec::numeric / NULLIF(sessions_this_week,0)) 
          OVER (PARTITION BY session_year, session_week), 2) AS avg_session_duration_week
FROM session_durations
ORDER BY session_year, session_week, user_id;
