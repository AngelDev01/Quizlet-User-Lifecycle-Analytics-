-- Users table
ALTER TABLE users 
    ALTER COLUMN signup_date TYPE DATE USING signup_date::DATE,
    ALTER COLUMN user_id TYPE INTEGER USING user_id::INTEGER;

-- Sets table
ALTER TABLE sets 
    ALTER COLUMN creation_date TYPE DATE USING creation_date::DATE,
    ALTER COLUMN card_count TYPE INTEGER USING card_count::INTEGER;

-- Subscriptions table
ALTER TABLE subscriptions 
    ALTER COLUMN start_date TYPE DATE USING start_date::DATE,
    ALTER COLUMN end_date TYPE DATE USING end_date::DATE,
    ALTER COLUMN price TYPE DECIMAL(10,2) USING price::DECIMAL(10,2);

-- Study sessions table
ALTER TABLE study_sessions 
    ALTER COLUMN start_time TYPE TIMESTAMP USING start_time::TIMESTAMP,
    ALTER COLUMN end_time TYPE TIMESTAMP USING end_time::TIMESTAMP,
    ALTER COLUMN duration_sec TYPE INTEGER USING duration_sec::INTEGER,
    ALTER COLUMN cards_studied TYPE INTEGER USING cards_studied::INTEGER;
