CREATE TABLE IF NOT EXISTS whellco_bank_accounts (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    account_type VARCHAR(32) NOT NULL,
    balance BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY account_unique (citizenid, account_type),
    INDEX citizenid_idx (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS whellco_bank_transactions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id INT UNSIGNED NOT NULL,
    transaction_type VARCHAR(32) NOT NULL,
    amount BIGINT NOT NULL,
    balance_after BIGINT NOT NULL,
    details VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX account_id_idx (account_id),
    CONSTRAINT fk_bank_transaction_account
        FOREIGN KEY (account_id)
        REFERENCES whellco_bank_accounts(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;