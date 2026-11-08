CREATE TABLE IF NOT EXISTS whellco_driver_exams (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    exam_type VARCHAR(32) NOT NULL,
    score INT NOT NULL,
    passed TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX citizen_idx (citizenid),
    INDEX exam_type_idx (exam_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;