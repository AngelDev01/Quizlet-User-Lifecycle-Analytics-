-- =============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================================================

-- Fact table indexes (foreign keys)
CREATE INDEX idx_fact_sessions_user_id ON analytics.fact_study_sessions(user_id);
CREATE INDEX idx_fact_sessions_set_id ON analytics.fact_study_sessions(set_id);
CREATE INDEX idx_fact_sessions_date_id ON analytics.fact_study_sessions(date_id);
CREATE INDEX idx_fact_sessions_plan ON analytics.fact_study_sessions(subscription_plan_at_time);

CREATE INDEX idx_fact_subscriptions_user_id ON analytics.fact_subscriptions(user_id);
CREATE INDEX idx_fact_subscriptions_plan_id ON analytics.fact_subscriptions(plan_id);
CREATE INDEX idx_fact_subscriptions_start_date_id ON analytics.fact_subscriptions(start_date_id);

CREATE INDEX idx_fact_set_creation_user_id ON analytics.fact_set_creation(user_id);
CREATE INDEX idx_fact_set_creation_date_id ON analytics.fact_set_creation(date_id);

-- Dimension table indexes (for filtering)
CREATE INDEX idx_dim_user_activation ON analytics.dim_user(activation_status);
CREATE INDEX idx_dim_user_is_premium ON analytics.dim_user(is_premium);
CREATE INDEX idx_dim_user_acquisition ON analytics.dim_user(acquisition_channel);

CREATE INDEX idx_dim_set_topic ON analytics.dim_set(topic);

CREATE INDEX idx_dim_date_year ON analytics.dim_date(year);
CREATE INDEX idx_dim_date_month ON analytics.dim_date(month);
CREATE INDEX idx_dim_date_quarter ON analytics.dim_date(quarter);
