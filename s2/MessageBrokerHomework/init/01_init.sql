CREATE TABLE IF NOT EXISTS tasks (
                                     id SERIAL PRIMARY KEY,
                                     payload TEXT NOT NULL,
                                     status VARCHAR(20) DEFAULT 'Ready',
    priority INT DEFAULT 0,
    attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT now(),
    scheduled_at TIMESTAMP DEFAULT now()
    );

CREATE INDEX IF NOT EXISTS idx_tasks_ready_process
    ON tasks (priority DESC, scheduled_at ASC)
    WHERE status = 'Ready';
