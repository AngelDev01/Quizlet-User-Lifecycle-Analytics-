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
