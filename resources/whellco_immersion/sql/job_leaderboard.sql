ALTER TABLE whellco_job_progress
    ADD COLUMN IF NOT EXISTS player_name VARCHAR(64) NULL AFTER identifier;

CREATE INDEX IF NOT EXISTS idx_whellco_job_progress_completed
    ON whellco_job_progress (completed_jobs DESC);
