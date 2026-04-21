-- MySQL schema for Secure Prison Management and Family Portal System
-- Assumption: database name `prison_management_db`

CREATE DATABASE IF NOT EXISTS prison_management_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE prison_management_db;

-- 1. roles
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- 2. users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL,
    reset_token VARCHAR(100) NULL,
    reset_token_expiry DATETIME NULL,
    is_locked TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_users_role_id (role_id),
    KEY idx_users_reset_token (reset_token),
    KEY idx_users_reset_token_expiry (reset_token_expiry),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- 3. prisoners
CREATE TABLE IF NOT EXISTS prisoners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prisoner_id VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    crime_type VARCHAR(100) NOT NULL,
    sentence_years INT NOT NULL,
    admission_date DATE NOT NULL,
    release_date DATE,
    block_number VARCHAR(20) NOT NULL,
    security_level VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    emergency_contact VARCHAR(100),
    photo_data_uri LONGTEXT,
    is_deleted TINYINT(1) NOT NULL DEFAULT 0,
    KEY idx_prisoners_status (status),
    KEY idx_prisoners_block_number (block_number),
    KEY idx_prisoners_security_level (security_level),
    KEY idx_prisoners_is_deleted (is_deleted)
);

-- 4. family_members
CREATE TABLE IF NOT EXISTS family_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    prisoner_id INT,
    relation VARCHAR(50),
    phone VARCHAR(30),
    address VARCHAR(255),
    KEY idx_family_members_user_id (user_id),
    KEY idx_family_members_prisoner_id (prisoner_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (prisoner_id) REFERENCES prisoners(id)
);

-- 5. visit_requests
CREATE TABLE IF NOT EXISTS visit_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prisoner_id INT NOT NULL,
    family_member_id INT NOT NULL,
    request_date DATE NOT NULL,
    preferred_visit_date DATE NOT NULL,
    relation VARCHAR(50),
    message TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_visit_requests_prisoner_id (prisoner_id),
    KEY idx_visit_requests_family_member_id (family_member_id),
    KEY idx_visit_requests_status (status),
    KEY idx_visit_requests_preferred_visit_date (preferred_visit_date),
    FOREIGN KEY (prisoner_id) REFERENCES prisoners(id),
    FOREIGN KEY (family_member_id) REFERENCES family_members(id)
);

-- 6. visit_schedule
CREATE TABLE IF NOT EXISTS visit_schedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    visit_request_id INT NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    room VARCHAR(50),
    notes VARCHAR(255),
    KEY idx_visit_schedule_visit_request_id (visit_request_id),
    KEY idx_visit_schedule_scheduled_date (scheduled_date),
    FOREIGN KEY (visit_request_id) REFERENCES visit_requests(id)
);

-- 7. prisoner_activities
CREATE TABLE IF NOT EXISTS prisoner_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prisoner_id INT NOT NULL,
    staff_user_id INT NOT NULL,
    activity_name VARCHAR(100) NOT NULL,
    description TEXT,
    activity_date DATE NOT NULL,
    KEY idx_prisoner_activities_prisoner_id (prisoner_id),
    KEY idx_prisoner_activities_activity_date (activity_date),
    FOREIGN KEY (prisoner_id) REFERENCES prisoners(id),
    FOREIGN KEY (staff_user_id) REFERENCES users(id)
);

-- 8. deleted_prisoners (archive for soft-deleted prisoners)
CREATE TABLE IF NOT EXISTS deleted_prisoners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prisoner_id INT NOT NULL,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by INT,
    reason VARCHAR(255),
    KEY idx_deleted_prisoners_prisoner_id (prisoner_id),
    KEY idx_deleted_prisoners_deleted_at (deleted_at),
    FOREIGN KEY (prisoner_id) REFERENCES prisoners(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

-- 9. login_attempts
CREATE TABLE IF NOT EXISTS login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    email VARCHAR(100) NOT NULL,
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success TINYINT(1) NOT NULL,
    ip_address VARCHAR(50),
    KEY idx_login_attempts_user_id (user_id),
    KEY idx_login_attempts_email (email),
    KEY idx_login_attempts_attempt_time (attempt_time),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 10. notifications
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_notifications_user_id (user_id),
    KEY idx_notifications_is_read (is_read),
    KEY idx_notifications_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 11. inquiries
CREATE TABLE IF NOT EXISTS inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    family_member_id INT,
    subject VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    KEY idx_inquiries_family_member_id (family_member_id),
    KEY idx_inquiries_created_at (created_at),
    FOREIGN KEY (family_member_id) REFERENCES family_members(id)
);

-- 12. activity_logs
CREATE TABLE IF NOT EXISTS activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_activity_logs_user_id (user_id),
    KEY idx_activity_logs_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Seed roles
INSERT INTO roles (name) VALUES
    ('ADMIN'),
    ('STAFF'),
    ('FAMILY')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Sample admin user (password hash placeholder to be updated after PasswordUtil decision)
-- Default admin login credentials for development:
-- email: admin@example.com
-- password: Admin@123
INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
VALUES (
    1,
    'Admin User',
    'admin@example.com',
    'Tfe/rHa36aztUKCRkQUO+1xQO0iSghHToAlNQrGeHX4=',
    'QWRtaW5TYWx0MjAyNg==',
    0
)
ON DUPLICATE KEY UPDATE
    full_name = VALUES(full_name),
    password_hash = VALUES(password_hash),
    password_salt = VALUES(password_salt),
    is_locked = 0;