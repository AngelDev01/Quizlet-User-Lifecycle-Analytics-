# Power BI Dashboard

Single-page executive dashboard for Quizlet product analytics. Built on PostgreSQL star schema with 7 analytics marts.


## Overview
| Aspect | Detail |
|--------|--------|
| **Purpose** | Weekly stakeholder reporting (leadership standups) |
| **Data Source** | PostgreSQL `analytics` schema (Gold layer) |
| **Connection** | Import |
| **Pages** | 1 |
| **Visuals** | 13 |
| **DAX Measures** | 5 |


## Mart-to-Visual Mapping
| Mart | Visual | Metric |
|------|--------|--------|
| `mart_wal_by_week` | Line chart | WAL trend |
| `mart_wal_by_week` | Card | Current WAL (DAX) |
| `mart_new_vs_returning_users` | Stacked area | New vs. Returning composition |
| `mart_activation_by_channel` | Clustered column | Activation rate by channel |
| `mart_activation_by_channel` | Card | Overall activation rate (DAX) |
| `mart_time_to_first_study` | Histogram | Time to first study |
| `mart_retention_cohort` | Matrix | Cohort retention heatmap |
| `mart_retention_cohort` | Card | Day-7 retention rate (DAX) |
| `mart_engagement_by_week` | Line chart | Sessions per user per week |
| `mart_engagement_by_week` | Line chart | Avg session duration (DAX) |
| `mart_time_to_upgrade` | Bar chart | Free→Trial→Paid comparison |
| `mart_time_to_upgrade` | Card | Free→Premium conversion (DAX) |
| `mart_time_to_upgrade` | Histogram | Time to upgrade distribution |


## DAX Measures
| Measure | Logic | Purpose |
|---------|-------|---------|
| `Current WAL` | `MAX(week_number)` → corresponding WAL | Latest week snapshot |
| `Overall Activation Rate` | `DIVIDE(SUM(activated), SUM(total), 0)` | Weighted across channels |
| `Day 7 Retention Rate` | `DIVIDE(SUMX(Day7, retained), SUMX(Day7, size), 0)` | Cohort-based, weighted |
| `Free to Premium Conversion` | Eligible free users vs. upgraded | Conversion funnel efficiency |
| `Avg Session Duration (Min)` | `DIVIDE(SUM(duration_sec), SUM(sessions) * 60, 0)` | Engagement depth |


## Design Decisions
- **Single-page layout:** All visuals visible simultaneously to surface cross-metric patterns (e.g., WAL plateau + retention correlation).
- **Bar chart for monetization:** Chosen over funnel to preserve accurate proportional comparison.
- **Retention matrix:** 6 signup cohorts (weeks 9–14) × 20 columns (3-day buckets over 60 days) balances granularity with scannability for drop-off pattern detection.


## Screenshots
| File | Shows |
|------|-------|
| `01_full_dashboard.png` | Complete single-page layout |
| `02_wal_growth.png` | WAL KPI card + WAL Trend line chart |
| `03_user_composition.png` | New vs Returning Users area chart |
| `04_activation_section.png` | Activation by Channel bar + Time to First Study histogram |
| `05_engagement_retention.png` | Cohort Retention heatmap |
| `06_monetization_section.png` | Free→Trial→Paid bar + Time to Upgrade histogram |




## Refresh Instructions
1. Open `quizlet_analytics.pbix` in Power BI Desktop
2. Verify PostgreSQL connection to `analytics` schema
3. **Home → Refresh** to pull from 7 mart views
4. **File → Publish** to Power BI Service (if sharing)
