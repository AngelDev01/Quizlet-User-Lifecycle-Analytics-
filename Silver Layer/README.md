# 🥈 Silver Layer — Cleaned & Validated Data

PostgreSQL `public` schema with proper types, standardized NULLs, and validated referential integrity.

  

## Row Counts
| Table | Rows | Key Constraints |
|-------|------|---------------|
| users | 10,000 | PK: user_id |
| sets | 15,898 | PK: set_id, FK: owner_user_id → users |
| subscriptions | 11,304 | PK: subscription_id, FK: user_id → users |
| study_sessions | 440,014 | PK: session_id, FK: user_id, set_id |

## Transformations Applied
| Step | File | Action |
|------|------|--------|
| 0 | `00_create_tables.sql` | Schema DDL with PK/FK constraints |
| 1 | `01_type_transformations.sql` | Cast dates, integers, decimals to proper types |
| 2 | `02_null_standardization.sql` | Empty strings → NULL, whitespace trimmed |
| 3 | `03_data_quality_checks.sql` | Orphan checks + NULL rate report |

## Data Quality Results
| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| Orphaned study_sessions | 0 | 0 | ✅ |
| Orphaned sets | 0 | 0 | ✅ |
| Orphaned subscriptions | 0 | 0 | ✅ |
| Invalid set refs in sessions | 0 | 0 | ✅ |
| users.country NULL rate | <5% | 2.5% | ⚠️ Intentional |
| subscriptions.end_date NULL | N/A | 82.4% | ⚠️ Active subs |

## Notes
- `country` NULLs: Intentional (privacy-preserving)
- `end_date` NULLs: Expected (NULL = active subscription)
