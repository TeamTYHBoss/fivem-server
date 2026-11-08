CREATE TABLE IF NOT EXISTS whellco_driving_lessons (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    instructor_citizenid VARCHAR(50) NOT NULL,
    student_citizenid VARCHAR(50) NOT NULL,
    lesson_type VARCHAR(32) NOT NULL,
    price BIGINT NOT NULL,
    passed TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX instructor_idx (instructor_citizenid),
    INDEX student_idx (student_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;