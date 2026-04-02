-- Check for orphaned study_sessions
SELECT COUNT(*) AS orphaned_sessions
FROM study_sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Check for orphaned sets
SELECT COUNT(*) AS orphaned_sets
FROM sets st
LEFT JOIN users u ON st.owner_user_id = u.user_id
WHERE u.user_id IS NULL;

-- Check for orphaned subscriptions
SELECT COUNT(*) AS orphaned_subscriptions
FROM subscriptions sub
LEFT JOIN users u ON sub.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Check sessions reference valid sets
SELECT COUNT(*) AS invalid_set_refs
FROM study_sessions s
LEFT JOIN sets st ON s.set_id = st.set_id
WHERE st.set_id IS NULL;


-- Comprehensive NULL Rate Report for all tables
WITH users_nulls AS (
    SELECT 
        'users' AS table_name,
        'user_id' AS column_name,
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN user_id IS NULL THEN 1 END) AS null_count
    FROM users
    UNION ALL
    SELECT 'users', 'signup_date', COUNT(*), COUNT(CASE WHEN signup_date IS NULL THEN 1 END) FROM users
    UNION ALL
    SELECT 'users', 'country', COUNT(*), COUNT(CASE WHEN country IS NULL THEN 1 END) FROM users
    UNION ALL
    SELECT 'users', 'age_group', COUNT(*), COUNT(CASE WHEN age_group IS NULL THEN 1 END) FROM users
    UNION ALL
    SELECT 'users', 'acquisition_channel', COUNT(*), COUNT(CASE WHEN acquisition_channel IS NULL THEN 1 END) FROM users
),
sets_nulls AS (
    SELECT 
        'sets' AS table_name,
        'set_id' AS column_name,
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN set_id IS NULL THEN 1 END) AS null_count
    FROM sets
    UNION ALL
    SELECT 'sets', 'owner_user_id', COUNT(*), COUNT(CASE WHEN owner_user_id IS NULL THEN 1 END) FROM sets
    UNION ALL
    SELECT 'sets', 'creation_date', COUNT(*), COUNT(CASE WHEN creation_date IS NULL THEN 1 END) FROM sets
    UNION ALL
    SELECT 'sets', 'topic', COUNT(*), COUNT(CASE WHEN topic IS NULL THEN 1 END) FROM sets
    UNION ALL
    SELECT 'sets', 'card_count', COUNT(*), COUNT(CASE WHEN card_count IS NULL THEN 1 END) FROM sets
),
subscriptions_nulls AS (
    SELECT 
        'subscriptions' AS table_name,
        'subscription_id' AS column_name,
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN subscription_id IS NULL THEN 1 END) AS null_count
    FROM subscriptions
    UNION ALL
    SELECT 'subscriptions', 'user_id', COUNT(*), COUNT(CASE WHEN user_id IS NULL THEN 1 END) FROM subscriptions
    UNION ALL
    SELECT 'subscriptions', 'start_date', COUNT(*), COUNT(CASE WHEN start_date IS NULL THEN 1 END) FROM subscriptions
    UNION ALL
    SELECT 'subscriptions', 'plan', COUNT(*), COUNT(CASE WHEN plan IS NULL THEN 1 END) FROM subscriptions
    UNION ALL
    SELECT 'subscriptions', 'end_date', COUNT(*), COUNT(CASE WHEN end_date IS NULL THEN 1 END) FROM subscriptions
    UNION ALL
    SELECT 'subscriptions', 'price', COUNT(*), COUNT(CASE WHEN price IS NULL THEN 1 END) FROM subscriptions
),
sessions_nulls AS (
    SELECT 
        'study_sessions' AS table_name,
        'session_id' AS column_name,
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN session_id IS NULL THEN 1 END) AS null_count
    FROM study_sessions
    UNION ALL
    SELECT 'study_sessions', 'user_id', COUNT(*), COUNT(CASE WHEN user_id IS NULL THEN 1 END) FROM study_sessions
    UNION ALL
    SELECT 'study_sessions', 'set_id', COUNT(*), COUNT(CASE WHEN set_id IS NULL THEN 1 END) FROM study_sessions
    UNION ALL
    SELECT 'study_sessions', 'start_time', COUNT(*), COUNT(CASE WHEN start_time IS NULL THEN 1 END) FROM study_sessions
    UNION ALL
    SELECT 'study_sessions', 'duration_sec', COUNT(*), COUNT(CASE WHEN duration_sec IS NULL THEN 1 END) FROM study_sessions
    UNION ALL
    SELECT 'study_sessions', 'cards_studied', COUNT(*), COUNT(CASE WHEN cards_studied IS NULL THEN 1 END) FROM study_sessions
)
SELECT 
    table_name,
    column_name,
    total_rows,
    null_count,
    ROUND(null_count * 100.0 / total_rows, 2) AS null_pct
FROM (
    SELECT * FROM users_nulls
    UNION ALL
    SELECT * FROM sets_nulls
    UNION ALL
    SELECT * FROM subscriptions_nulls
    UNION ALL
    SELECT * FROM sessions_nulls
) all_nulls
ORDER BY table_name, column_name
