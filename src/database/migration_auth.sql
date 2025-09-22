-- Migration for authentication/authorization support

-- Refresh tokens table for rotating refresh tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token TEXT NOT NULL,
  revoked TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes if they don't already exist (MySQL doesn't support IF NOT EXISTS for indexes directly)
SET @exists_user_idx := (
  SELECT COUNT(1) FROM INFORMATION_SCHEMA.STATISTICS 
  WHERE table_schema = DATABASE() AND table_name = 'refresh_tokens' AND index_name = 'idx_refresh_tokens_user'
);
SET @exists_expires_idx := (
  SELECT COUNT(1) FROM INFORMATION_SCHEMA.STATISTICS 
  WHERE table_schema = DATABASE() AND table_name = 'refresh_tokens' AND index_name = 'idx_refresh_tokens_expires'
);

SET @sql_user_idx = IF(@exists_user_idx = 0, 'CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);', 'SELECT 1');
PREPARE stmt1 FROM @sql_user_idx; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;

SET @sql_expires_idx = IF(@exists_expires_idx = 0, 'CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);', 'SELECT 1');
PREPARE stmt2 FROM @sql_expires_idx; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;
