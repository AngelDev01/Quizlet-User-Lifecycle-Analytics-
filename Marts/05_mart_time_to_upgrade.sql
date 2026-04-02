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
