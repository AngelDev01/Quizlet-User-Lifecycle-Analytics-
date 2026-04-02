-- Convert empty strings and 'NULL' text to actual NULLs
UPDATE users SET country = NULL WHERE country = '' OR country = 'NULL';
UPDATE users SET age_group = NULL WHERE age_group = '' OR age_group = 'NULL';

-- Trim whitespace from text columns
UPDATE users SET country = TRIM(country);
UPDATE users SET age_group = TRIM(age_group);
UPDATE users SET acquisition_channel = TRIM(acquisition_channel);

UPDATE sets SET topic = TRIM(topic);
UPDATE subscriptions SET plan = TRIM(plan);
UPDATE subscriptions SET status = TRIM(status);
