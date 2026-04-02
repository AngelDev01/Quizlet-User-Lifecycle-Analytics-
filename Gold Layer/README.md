# ⭐ Gold Layer — Star Schema

Kimball dimensional model in `analytics` schema for optimized querying. Surrogate integer date keys enable fast time-intelligence joins.

## Schema Overview
| Type | Table | Grain | Rows | Source |
|------|-------|-------|------|--------|
| **Dimension** | dim_date | 1 day | 61 | Generated (Mar 1–Apr 30, 2026) |
| **Dimension** | dim_user | 1 user | 10,000 | users + activation/premium flags |
| **Dimension** | dim_set | 1 set | 15,898 | sets |
| **Dimension** | dim_subscription_plan | 1 plan | 3 | subscriptions (distinct) |
| **Fact** | fact_study_sessions | 1 session | 440,014 | study_sessions |
| **Fact** | fact_subscriptions | 1 subscription | 11,304 | subscriptions |
| **Fact** | fact_set_creation | 1 set created | 15,898 | sets |

## Key Design Decisions  
| Decision | Rationale |
|----------|-----------|
| Integer `date_id` (YYYYMMDD) | Faster JOINs than DATE; enables time-series analysis |
| Type 1 SCD (overwrite) | Portfolio scope: latest state only |
| `subscription_plan_at_time` in fact_study_sessions | Avoids complex temporal joins for "what plan was user on during session?" |
| Pre-calculated `duration_days` | Supports cohort LTV analysis without date arithmetic |

## Relationships
fact_study_sessions → dim_user, dim_set, dim_date
fact_subscriptions → dim_user,
dim_subscription_plan, dim_date (×2)
fact_set_creation → dim_user, dim_date
