-- =============================================================================
-- VALIDATION QUERIES
-- =============================================================================

-- 5.1 Verify row counts match Silver layer
SELECT 
    'dim_date' AS table_name, COUNT(*) AS gold_rows, 
    (SELECT COUNT(*) FROM GENERATE_SERIES('2026-03-01'::DATE, '2026-04-30'::DATE, '1 day'::INTERVAL)) AS expected
FROM analytics.dim_date
UNION ALL
SELECT 'dim_user', COUNT(*), (SELECT COUNT(*) FROM public.users)
FROM analytics.dim_user
UNION ALL
SELECT 'dim_set', COUNT(*), (SELECT COUNT(*) FROM public.sets)
FROM analytics.dim_set
UNION ALL
SELECT 'fact_study_sessions', COUNT(*), (SELECT COUNT(*) FROM public.study_sessions)
FROM analytics.fact_study_sessions
UNION ALL
SELECT 'fact_subscriptions', COUNT(*), (SELECT COUNT(*) FROM public.subscriptions)
FROM analytics.fact_subscriptions;

-- 5.2 Check for orphaned foreign keys
SELECT 'fact_sessions → dim_user' AS check_name, COUNT(*) AS orphaned
FROM analytics.fact_study_sessions f
LEFT JOIN analytics.dim_user d ON f.user_id = d.user_id
WHERE d.user_id IS NULL
UNION ALL
SELECT 'fact_sessions → dim_set', COUNT(*)
FROM analytics.fact_study_sessions f
LEFT JOIN analytics.dim_set d ON f.set_id = d.set_id
WHERE d.set_id IS NULL
UNION ALL
SELECT 'fact_sessions → dim_date', COUNT(*)
FROM analytics.fact_study_sessions f
LEFT JOIN analytics.dim_date d ON f.date_id = d.date_id
WHERE d.date_id IS NULL
UNION ALL
SELECT 'fact_subscriptions → dim_user', COUNT(*)
FROM analytics.fact_subscriptions f
LEFT JOIN analytics.dim_user d ON f.user_id = d.user_id
WHERE d.user_id IS NULL
UNION ALL
SELECT 'fact_subscriptions → dim_subscription_plan', COUNT(*)
FROM analytics.fact_subscriptions f
LEFT JOIN analytics.dim_subscription_plan d ON f.plan_id = d.plan_id
WHERE d.plan_id IS NULL;

-- 5.3 Verify no duplicate primary keys
SELECT 'fact_study_sessions' AS table_name, session_id, COUNT(*) 
FROM analytics.fact_study_sessions 
GROUP BY session_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'fact_subscriptions', subscription_id, COUNT(*) 
FROM analytics.fact_subscriptions 
GROUP BY subscription_id HAVING COUNT(*) > 1;

-- 5.4 Verify date coverage
SELECT 
    MIN(d.date) AS min_date,
    MAX(d.date) AS max_date,
    COUNT(*) AS total_days
FROM analytics.dim_date d;
