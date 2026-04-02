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
