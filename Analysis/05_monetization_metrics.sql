-- ==========================================
-- Monetization Funnel
-- M4.1: Free → Premium Conversion
-- M4.2: Trial → Paid Conversion
-- ==========================================
WITH user_plan_flags AS (
    -- Determine whether each user ever had each plan type
    SELECT
        fs.user_id,
        MAX(CASE WHEN dsp.plan_name = 'free' THEN 1 ELSE 0 END) AS has_free,
        MAX(CASE WHEN dsp.plan_name = 'trial' THEN 1 ELSE 0 END) AS has_trial,
        MAX(CASE WHEN dsp.plan_name = 'premium' THEN 1 ELSE 0 END) AS has_premium
    FROM analytics.fact_subscriptions fs
    JOIN analytics.dim_subscription_plan dsp
        USING(plan_id)
    GROUP BY fs.user_id
),

funnel_counts AS (
    SELECT
        COUNT(*) AS total_users,
        SUM(has_free) AS free_users,
        SUM(has_trial) AS trial_users,
        SUM(has_premium) AS premium_users,
        SUM(CASE WHEN has_trial = 1 AND has_premium = 1 THEN 1 ELSE 0 END) AS trial_to_paid_users --users who had trial AND later had premium
    FROM user_plan_flags
)

SELECT
    total_users,
    free_users,
    trial_users,
    premium_users,
    trial_to_paid_users,

    -- M4.1 Free → Premium
    ROUND(premium_users::numeric / NULLIF(free_users,0) * 100, 2)
        AS free_to_premium_conversion_pct,

    -- M4.2 Trial → Paid
    ROUND(trial_to_paid_users::numeric / NULLIF(trial_users,0) * 100, 2)
        AS trial_to_paid_conversion_pct

FROM funnel_counts;


-- ==========================================
-- M4.3: Time to Upgrade (Free/Trial → Premium)
-- Calculates days between first free/trial subscription and first premium subscription
-- ==========================================
WITH first_subscription AS (
    -- Get first subscription date per plan type per user
    SELECT
        fs.user_id,
        MIN(CASE WHEN dsp.plan_name = 'free' THEN d.date END) AS free_start_date,
        MIN(CASE WHEN dsp.plan_name = 'trial' THEN d.date END) AS trial_start_date,
        MIN(CASE WHEN dsp.plan_name = 'premium' THEN d.date END) AS premium_start_date
    FROM analytics.fact_subscriptions fs
    JOIN analytics.dim_subscription_plan dsp
        USING(plan_id)
    JOIN analytics.dim_date d
        ON fs.start_date_id = d.date_id
    GROUP BY fs.user_id
),

upgrade_days AS (
    -- Calculate upgrade times in days
    SELECT
        user_id,
        free_start_date,
        trial_start_date,
        premium_start_date,
        premium_start_date - free_start_date AS free_to_premium_days,
        premium_start_date - trial_start_date AS trial_to_premium_days
    FROM first_subscription
)

-- Final output with eligibility flags for accurate conversion metrics
SELECT
    user_id,
    free_start_date,
    trial_start_date,
    premium_start_date,
    free_to_premium_days,
    trial_to_premium_days,
    -- Flag: Was user ever on a free plan? (for conversion rate denominator)
    CASE WHEN free_start_date IS NOT NULL THEN TRUE ELSE FALSE END AS was_ever_free,
    -- Flag: Did user ever upgrade to premium? (for conversion rate numerator)
    CASE WHEN premium_start_date IS NOT NULL THEN TRUE ELSE FALSE END AS did_upgrade,
    -- Flag: What was the upgrade path?
    CASE 
        WHEN free_start_date IS NOT NULL AND premium_start_date IS NOT NULL THEN 'free_to_premium'
        WHEN trial_start_date IS NOT NULL AND premium_start_date IS NOT NULL THEN 'trial_to_premium'
        WHEN premium_start_date IS NOT NULL THEN 'direct_premium'
        ELSE 'free_only'
    END AS upgrade_path
FROM upgrade_days
ORDER BY user_id
