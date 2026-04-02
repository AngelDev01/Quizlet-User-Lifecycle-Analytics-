-- =============================================================================
-- M1.1 Activation Rate
-- Percentage of users who completed the activation event
-- (activation_status already encodes whether the user activated)
-- =============================================================================
SELECT
  COUNT(user_id) AS total_users,
  COUNT(*) FILTER (WHERE activation_status = 'Active') AS activated_users,
  ROUND(
    COUNT(*) FILTER (WHERE activation_status = 'Active')::numeric
    / NULLIF(COUNT(user_id), 0) * 100,
    2
  ) AS pct_activated
FROM analytics.dim_user;


-- =============================================================================
-- M1.2 Time to First Study
-- Measure how long it takes users to complete their first study session after signup.
-- =============================================================================
WITH time_to_first_study AS (
  SELECT
    u.user_id,
    u.signup_date,
    fss.first_study_session,
    (fss.first_study_session - u.signup_date) AS days_to_first_study
  FROM (
    SELECT
      user_id,
      MIN(start_time)::date AS first_study_session
    FROM analytics.fact_study_sessions
    GROUP BY user_id
  ) fss
  JOIN analytics.dim_user u
    USING (user_id)
)

SELECT
  MIN(days_to_first_study) AS min_days_to_first_study,
  ROUND(AVG(days_to_first_study),2) AS avg_days_to_first_study,
  MAX(days_to_first_study) AS max_days_to_first_study
FROM time_to_first_study;


-- =============================================================================
-- M1.3 Activation by Channel
-- Compare activation rates across acquisition channels.
-- =============================================================================
WITH channel_activation AS (
  SELECT
    acquisition_channel,
    COUNT(user_id) AS total_users,
    COUNT(*) FILTER (WHERE activation_status = 'Active') AS activated_users
  FROM analytics.dim_user
  GROUP BY acquisition_channel
)

SELECT
  acquisition_channel,
  total_users,
  activated_users,
  ROUND(
    activated_users::numeric / NULLIF(total_users,0) * 100,
    2
  ) AS activation_rate
FROM channel_activation
ORDER BY activation_rate DESC;
