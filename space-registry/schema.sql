-- Perplexity Space Registry Database Schema

-- Main registry table: Maps projects to Spaces
CREATE TABLE IF NOT EXISTS space_registry (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_path TEXT UNIQUE NOT NULL,
    project_name TEXT NOT NULL,
    space_url TEXT NOT NULL,
    space_name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_used DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'active' CHECK(status IN ('active', 'archived', 'deleted')),
    metadata TEXT -- JSON string for additional data
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_project_path ON space_registry(project_path);
CREATE INDEX IF NOT EXISTS idx_space_url ON space_registry(space_url);
CREATE INDEX IF NOT EXISTS idx_status ON space_registry(status);
CREATE INDEX IF NOT EXISTS idx_last_used ON space_registry(last_used);

-- Log table: Track all Space operations
CREATE TABLE IF NOT EXISTS space_creation_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_path TEXT NOT NULL,
    action TEXT NOT NULL CHECK(action IN ('create', 'update', 'delete', 'archive')),
    status TEXT NOT NULL CHECK(status IN ('success', 'failure', 'pending')),
    error_message TEXT,
    duration_ms INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Index for log queries
CREATE INDEX IF NOT EXISTS idx_log_project ON space_creation_log(project_path);
CREATE INDEX IF NOT EXISTS idx_log_created ON space_creation_log(created_at);

-- Settings table: Store configuration
CREATE TABLE IF NOT EXISTS registry_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT OR IGNORE INTO registry_settings (key, value) VALUES
    ('auto_create_spaces', 'true'),
    ('default_space_prefix', 'Project: '),
    ('browser_timeout_ms', '30000'),
    ('max_retry_attempts', '3');
