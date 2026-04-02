-- =============================================================================
-- QUIZLET PRODUCT ANALYTICS - DATABASE SCHEMA
-- =============================================================================

-- USERS TABLE
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    signup_date DATE NOT NULL,
    country VARCHAR(100),
    age_group VARCHAR(20),
    acquisition_channel VARCHAR(50)
);

-- SETS TABLE
CREATE TABLE sets (
    set_id INTEGER PRIMARY KEY,
    owner_user_id INTEGER NOT NULL,
    creation_date DATE NOT NULL,
    topic VARCHAR(50),
    card_count INTEGER CHECK (card_count BETWEEN 5 AND 50),
    FOREIGN KEY (owner_user_id) REFERENCES users(user_id)
);

-- SUBSCRIPTIONS TABLE
CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    plan VARCHAR(20) CHECK (plan IN ('free', 'trial', 'premium')),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) CHECK (status IN ('active', 'expired', 'canceled')),
    price DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- STUDY_SESSIONS TABLE
CREATE TABLE study_sessions (
    session_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    set_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    duration_sec INTEGER,
    cards_studied INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (set_id) REFERENCES sets(set_id)
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

CREATE INDEX idx_users_signup ON users(signup_date);
CREATE INDEX idx_sets_owner ON sets(owner_user_id);
CREATE INDEX idx_sessions_user ON study_sessions(user_id);
CREATE INDEX idx_sessions_date ON study_sessions(start_time);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
