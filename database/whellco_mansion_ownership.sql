CREATE TABLE IF NOT EXISTS whellco_mansion_ownership (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mansion_id VARCHAR(100) NOT NULL,
    owner_citizenid VARCHAR(50) NOT NULL,
    purchase_price INT UNSIGNED NOT NULL,
    wall_colour VARCHAR(50) DEFAULT 'ivory',
    floor_style VARCHAR(50) DEFAULT 'marble',
    lighting_mode VARCHAR(50) DEFAULT 'warm',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY mansion_unique (mansion_id),
    INDEX owner_idx (owner_citizenid),
    INDEX created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_mansion_guests (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mansion_id VARCHAR(100) NOT NULL,
    guest_citizenid VARCHAR(50) NOT NULL,
    added_by VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY guest_unique (mansion_id, guest_citizenid),
    INDEX mansion_idx (mansion_id),
    INDEX guest_idx (guest_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_mansion_events (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mansion_id VARCHAR(100) NOT NULL,
    host_citizenid VARCHAR(50) NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    ends_at INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX mansion_idx (mansion_id),
    INDEX host_idx (host_citizenid),
    INDEX ends_idx (ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_mansion_cameras (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mansion_id VARCHAR(100) NOT NULL,
    owner_citizenid VARCHAR(50) NOT NULL,
    camera_name VARCHAR(100) NOT NULL,
    coords_x FLOAT NOT NULL,
    coords_y FLOAT NOT NULL,
    coords_z FLOAT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX mansion_idx (mansion_id),
    INDEX owner_idx (owner_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;