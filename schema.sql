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
    is_locked TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
    is_deleted TINYINT(1) NOT NULL DEFAULT 0
);

-- 4. family_members
CREATE TABLE IF NOT EXISTS family_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    prisoner_id INT,
    relation VARCHAR(50),
    phone VARCHAR(30),
    address VARCHAR(255),
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
    FOREIGN KEY (family_member_id) REFERENCES family_members(id)
);

-- 12. activity_logs
CREATE TABLE IF NOT EXISTS activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Seed roles
INSERT INTO roles (name) VALUES
    ('ADMIN'),
    ('STAFF'),
    ('FAMILY')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Sample admin user (password hash placeholder to be updated after PasswordUtil decision)
-- For now, insert a dummy row; you will update password_hash and salt via Java utility.
INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
VALUES (1, 'Admin User', 'admin@example.com', 'CHANGE_ME_HASH', 'CHANGE_ME_SALT', 0)
ON DUPLICATE KEY UPDATE email = email;