# 🎯 Analytics Marts — Production Views

Clean, denormalized outputs optimized for BI tools and reporting. Each mart maps 1:1 to a Power BI table.


## Mart Catalog
| Mart | File | Power BI Table | Grain | Key Columns |
|------|------|----------------|-------|-------------|
| WAL Trend | `01_mart_wal_by_week.sql` | WAL Trend | 1 row = 1 week | week_number, weekly_active_learners |
| Activation | `02_mart_activation_by_channel.sql` | Activation by Channel | 1 row = 1 channel | channel, total_users, activated_users, activation_rate |
| Retention | `03_mart_retention_cohort.sql` | Retention Cohorts | 1 row = 1 cohort × day | signup_week, days_since_signup, cohort_retained, cohort_size, pct_retained |
| Engagement | `04_mart_engagement_by_week.sql` | Weekly Engagement | 1 row = 1 user × week | session_week, user_id, sessions_this_week, total_duration_sec, avg_session_duration_sec |
| Time to Upgrade | `05_mart_time_to_upgrade.sql` | Time to Upgrade | 1 row = 1 user | user_id, free_start_date, trial_start_date, premium_start_date, free_to_premium_days, upgrade_path |
| New vs Returning | `06_mart_new_vs_returning_users.sql` | New vs Returning Users | 1 row = 1 week | week_start, new_users, returning_users, total_wal, pct_new_users, pct_returning_users |
| Time to First Study | `07_mart_time_to_first_study.sql` | Time to First Study | 1 row = 1 user (activated only) | user_id, signup_date, first_study_session, days_to_first_study |


## Design Principles
- **No CTEs in final SELECT**: Flat structure for easy BI import
- **Explicit column names**: No `SELECT *`, no ambiguous aliases
- **Sorted output**: `ORDER BY` primary dimension for predictable BI behavior
- **Single grain per mart**: No mixed granularities (no user + session in same row)
