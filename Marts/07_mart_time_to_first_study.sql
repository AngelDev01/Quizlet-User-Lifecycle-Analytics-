-- M1.2 Time to First Study
-- Measure how long it takes users to complete their first study session after signup.

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
  *
FROM time_to_first_study;
