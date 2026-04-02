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
    week AS week_number,                       -- week number
    wal AS weekly_active_learners
FROM weekly_wal
ORDER BY week ASC;
