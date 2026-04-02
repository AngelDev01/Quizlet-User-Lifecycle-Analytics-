-- M1.3 Activation by Channel
-- Compare activation rates across acquisition channels.

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
