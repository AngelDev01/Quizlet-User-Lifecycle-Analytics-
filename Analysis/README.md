# 📊 Analytics Queries — Business Logic

SQL queries answering the core business questions. Each file maps to a specific stakeholder need.  

## Question-to-Query Mapping
| Business Question | File | Key Output | Stakeholder |
|-------------------|------|------------|-------------|
| "Is our user base growing?" | `01_growth_metrics.sql` | Weekly Active Learners (WAL) trend | Executive |
| "Which acquisition channel performs best?" | `02_activation_metrics.sql` | Activation rate by channel | Marketing |
| "Are we retaining users?" | `03_retention_metrics.sql` | Cohort retention matrix (D7/D30) | Product |
| "How engaged are our users?" | `04_engagement_metrics.sql` | Sessions per user, avg duration | Product |
| "Is our monetization working?" | `05_monetization_metrics.sql` | Free→Trial→Premium funnel | Finance |

## Metric Definitions
| Metric | Definition | SQL Logic |
|--------|-----------|-----------|
| **WAL** | Distinct users with ≥1 study session in ISO week | `COUNT(DISTINCT user_id)` per `week_number` |
| **Activation** | User completed first study session | `MIN(start_time)` exists for user |
| **D7 Retention** | % of signup cohort active on day 7 | Cohort-based: `days_since_signup = 7` |
| **DAU/MAU** | Daily active / Monthly active ratio | `date_trunc` aggregation |
| **Free→Premium** | % of free users who ever upgrade | Time-bound subscription lookup |

## Design Patterns
- **CTEs for readability**: Each query uses `WITH` clauses named by purpose (`weekly_wal`, `cohort_sizes`, `retention_summary`)
- **Surrogate date keys**: All queries JOIN to `dim_date` for time intelligence
- **Reproducible**: No hardcoded dates; relative to `min(signup_date)` where applicable

## Dependencies
All queries assume `analytics` schema (Gold layer) exists with:
- `dim_user`, `dim_set`, `dim_date`, `dim_subscription_plan`
- `fact_study_sessions`, `fact_subscriptions`, `fact_set_creation`
