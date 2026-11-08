ALTER TABLE whellco_player_reports
    ADD COLUMN claimed_by VARCHAR(50) NULL AFTER status,
    ADD COLUMN closed_by VARCHAR(50) NULL AFTER claimed_by,
    ADD COLUMN resolution_note VARCHAR(500) NULL AFTER closed_by;

CREATE INDEX claimed_idx ON whellco_player_reports (claimed_by);
CREATE INDEX closed_idx ON whellco_player_reports (closed_by);