-- Migration: seed Nepal-relevant sample data for prison_management_db
-- Safe to run multiple times (uses NOT EXISTS guards)

USE prison_management_db;

-- -----------------------------------------------------------------------------
-- 1) Roles (idempotent)
-- -----------------------------------------------------------------------------
INSERT INTO roles (name)
SELECT 'ADMIN'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ADMIN');

INSERT INTO roles (name)
SELECT 'STAFF'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'STAFF');

INSERT INTO roles (name)
SELECT 'FAMILY'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'FAMILY');

-- -----------------------------------------------------------------------------
-- 2) Users (password_hash/salt are demo placeholders)
-- -----------------------------------------------------------------------------
-- Default development admin credentials:
-- email: admin@example.com
-- password: Admin@123
INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Admin User', 'admin@example.com',
     'Tfe/rHa36aztUKCRkQUO+1xQO0iSghHToAlNQrGeHX4=',
     'QWRtaW5TYWx0MjAyNg==',
     0
FROM roles r
WHERE r.name = 'ADMIN'
ON DUPLICATE KEY UPDATE
  role_id = VALUES(role_id),
  full_name = VALUES(full_name),
  password_hash = VALUES(password_hash),
  password_salt = VALUES(password_salt),
  is_locked = 0;

INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Super Admin Kathmandu', 'admin.kathmandu@pms.gov.np', 'DEMO_HASH_ADMIN_001', 'DEMO_SALT_ADMIN_001', 0
FROM roles r
WHERE r.name = 'ADMIN'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin.kathmandu@pms.gov.np');

INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Inspector Nabin Karki', 'nabin.karki@pms.gov.np', 'DEMO_HASH_STAFF_001', 'DEMO_SALT_STAFF_001', 0
FROM roles r
WHERE r.name = 'STAFF'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'nabin.karki@pms.gov.np');

INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Officer Sita Rai', 'sita.rai@pms.gov.np', 'DEMO_HASH_STAFF_002', 'DEMO_SALT_STAFF_002', 0
FROM roles r
WHERE r.name = 'STAFF'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'sita.rai@pms.gov.np');

INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Sita Thapa', 'sita.thapa.family@gmail.com', 'DEMO_HASH_FAMILY_001', 'DEMO_SALT_FAMILY_001', 0
FROM roles r
WHERE r.name = 'FAMILY'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'sita.thapa.family@gmail.com');

INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Ram Gurung', 'ram.gurung.family@gmail.com', 'DEMO_HASH_FAMILY_002', 'DEMO_SALT_FAMILY_002', 0
FROM roles r
WHERE r.name = 'FAMILY'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'ram.gurung.family@gmail.com');

INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked)
SELECT r.id, 'Mina Tamang', 'mina.tamang.family@gmail.com', 'DEMO_HASH_FAMILY_003', 'DEMO_SALT_FAMILY_003', 0
FROM roles r
WHERE r.name = 'FAMILY'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'mina.tamang.family@gmail.com');

-- -----------------------------------------------------------------------------
-- 3) Prisoners
-- -----------------------------------------------------------------------------
INSERT INTO prisoners (
    prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years,
    admission_date, release_date, block_number, security_level, status,
    emergency_contact, photo_data_uri, is_deleted
)
SELECT
    'NP-PMS-0142', 'Ramesh Karki', '1985-05-12', 'Male', 'Organized Theft', 6,
    '2023-10-15', '2029-10-14', 'B', 'Medium', 'Active',
    '+977-9801112233', NULL, 0
WHERE NOT EXISTS (SELECT 1 FROM prisoners WHERE prisoner_id = 'NP-PMS-0142');

INSERT INTO prisoners (
    prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years,
    admission_date, release_date, block_number, security_level, status,
    emergency_contact, photo_data_uri, is_deleted
)
SELECT
    'NP-PMS-0231', 'Suman Karki', '1991-02-20', 'Male', 'Fraud', 4,
    '2024-01-10', '2028-01-09', 'A', 'Low', 'Active',
    '+977-9814456677', NULL, 0
WHERE NOT EXISTS (SELECT 1 FROM prisoners WHERE prisoner_id = 'NP-PMS-0231');

INSERT INTO prisoners (
    prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years,
    admission_date, release_date, block_number, security_level, status,
    emergency_contact, photo_data_uri, is_deleted
)
SELECT
    'NP-PMS-0318', 'Dawa Lama', '1988-11-08', 'Male', 'Narcotics Trafficking', 10,
    '2022-06-05', '2032-06-04', 'E', 'High', 'Active',
    '+977-9842233445', NULL, 0
WHERE NOT EXISTS (SELECT 1 FROM prisoners WHERE prisoner_id = 'NP-PMS-0318');

INSERT INTO prisoners (
    prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years,
    admission_date, release_date, block_number, security_level, status,
    emergency_contact, photo_data_uri, is_deleted
)
SELECT
    'NP-PMS-0410', 'Bikash Shrestha', '1982-09-17', 'Male', 'Assault', 5,
    '2021-04-12', '2026-04-11', 'C', 'Medium', 'Transferred',
    '+977-9856677889', NULL, 0
WHERE NOT EXISTS (SELECT 1 FROM prisoners WHERE prisoner_id = 'NP-PMS-0410');

INSERT INTO prisoners (
    prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years,
    admission_date, release_date, block_number, security_level, status,
    emergency_contact, photo_data_uri, is_deleted
)
SELECT
    'NP-PMS-0502', 'Nirmal Poudel', '1979-01-25', 'Male', 'Financial Embezzlement', 7,
    '2020-08-20', '2027-08-19', 'D', 'Low', 'Released',
    '+977-9861122334', NULL, 0
WHERE NOT EXISTS (SELECT 1 FROM prisoners WHERE prisoner_id = 'NP-PMS-0502');

INSERT INTO prisoners (
    prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years,
    admission_date, release_date, block_number, security_level, status,
    emergency_contact, photo_data_uri, is_deleted
)
SELECT
    'NP-PMS-0609', 'Arjun Rai', '1990-03-09', 'Male', 'Illegal Arms Possession', 8,
    '2023-02-18', '2031-02-17', 'D', 'High', 'Active',
    '+977-9809988776', NULL, 1
WHERE NOT EXISTS (SELECT 1 FROM prisoners WHERE prisoner_id = 'NP-PMS-0609');

-- -----------------------------------------------------------------------------
-- 4) Family members (links FAMILY users to prisoners)
-- -----------------------------------------------------------------------------
INSERT INTO family_members (user_id, prisoner_id, relation, phone, address)
SELECT u.id, p.id, 'Spouse', '+977-9803001122', 'Kalanki, Kathmandu'
FROM users u
JOIN prisoners p ON p.prisoner_id = 'NP-PMS-0142'
WHERE u.email = 'sita.thapa.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM family_members fm
      WHERE fm.user_id = u.id AND fm.prisoner_id = p.id
  );

INSERT INTO family_members (user_id, prisoner_id, relation, phone, address)
SELECT u.id, p.id, 'Brother', '+977-9817766554', 'Lakeside, Pokhara'
FROM users u
JOIN prisoners p ON p.prisoner_id = 'NP-PMS-0231'
WHERE u.email = 'ram.gurung.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM family_members fm
      WHERE fm.user_id = u.id AND fm.prisoner_id = p.id
  );

INSERT INTO family_members (user_id, prisoner_id, relation, phone, address)
SELECT u.id, p.id, 'Mother', '+977-9845566778', 'Dharan-12, Sunsari'
FROM users u
JOIN prisoners p ON p.prisoner_id = 'NP-PMS-0318'
WHERE u.email = 'mina.tamang.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM family_members fm
      WHERE fm.user_id = u.id AND fm.prisoner_id = p.id
  );

-- -----------------------------------------------------------------------------
-- 5) Visit requests
-- -----------------------------------------------------------------------------
INSERT INTO visit_requests (
    prisoner_id, family_member_id, request_date, preferred_visit_date,
    relation, message, status
)
SELECT p.id, fm.id, '2026-04-10', '2026-04-19', fm.relation,
       'Requesting regular monthly family visit for emotional support.', 'APPROVED'
FROM prisoners p
JOIN family_members fm ON fm.prisoner_id = p.id
JOIN users u ON u.id = fm.user_id
WHERE p.prisoner_id = 'NP-PMS-0142' AND u.email = 'sita.thapa.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM visit_requests vr
      WHERE vr.prisoner_id = p.id
        AND vr.family_member_id = fm.id
        AND vr.preferred_visit_date = '2026-04-19'
  );

INSERT INTO visit_requests (
    prisoner_id, family_member_id, request_date, preferred_visit_date,
    relation, message, status
)
SELECT p.id, fm.id, '2026-04-12', '2026-04-22', fm.relation,
       'Need to discuss legal document update with family member.', 'PENDING'
FROM prisoners p
JOIN family_members fm ON fm.prisoner_id = p.id
JOIN users u ON u.id = fm.user_id
WHERE p.prisoner_id = 'NP-PMS-0231' AND u.email = 'ram.gurung.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM visit_requests vr
      WHERE vr.prisoner_id = p.id
        AND vr.family_member_id = fm.id
        AND vr.preferred_visit_date = '2026-04-22'
  );

INSERT INTO visit_requests (
    prisoner_id, family_member_id, request_date, preferred_visit_date,
    relation, message, status
)
SELECT p.id, fm.id, '2026-04-13', '2026-04-24', fm.relation,
       'Health follow-up visit request from mother.', 'REJECTED'
FROM prisoners p
JOIN family_members fm ON fm.prisoner_id = p.id
JOIN users u ON u.id = fm.user_id
WHERE p.prisoner_id = 'NP-PMS-0318' AND u.email = 'mina.tamang.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM visit_requests vr
      WHERE vr.prisoner_id = p.id
        AND vr.family_member_id = fm.id
        AND vr.preferred_visit_date = '2026-04-24'
  );

-- -----------------------------------------------------------------------------
-- 6) Visit schedule (for approved request)
-- -----------------------------------------------------------------------------
INSERT INTO visit_schedule (visit_request_id, scheduled_date, scheduled_time, room, notes)
SELECT vr.id, '2026-04-19', '10:30:00', 'Room-2', 'Bring original citizenship card at gate check.'
FROM visit_requests vr
JOIN prisoners p ON p.id = vr.prisoner_id
WHERE p.prisoner_id = 'NP-PMS-0142'
  AND vr.preferred_visit_date = '2026-04-19'
  AND vr.status = 'APPROVED'
  AND NOT EXISTS (
      SELECT 1 FROM visit_schedule vs WHERE vs.visit_request_id = vr.id
  );

-- -----------------------------------------------------------------------------
-- 7) Prisoner activities
-- -----------------------------------------------------------------------------
INSERT INTO prisoner_activities (
    prisoner_id, staff_user_id, activity_name, description, activity_date
)
SELECT p.id, s.id, 'Medical Checkup', 'Routine monthly medical examination completed.', '2026-04-14'
FROM prisoners p
JOIN users s ON s.email = 'nabin.karki@pms.gov.np'
WHERE p.prisoner_id = 'NP-PMS-0142'
  AND NOT EXISTS (
      SELECT 1 FROM prisoner_activities pa
      WHERE pa.prisoner_id = p.id
        AND pa.staff_user_id = s.id
        AND pa.activity_name = 'Medical Checkup'
        AND pa.activity_date = '2026-04-14'
  );

INSERT INTO prisoner_activities (
    prisoner_id, staff_user_id, activity_name, description, activity_date
)
SELECT p.id, s.id, 'Court Transfer', 'Transferred under escort for Patan High Court hearing.', '2026-04-15'
FROM prisoners p
JOIN users s ON s.email = 'sita.rai@pms.gov.np'
WHERE p.prisoner_id = 'NP-PMS-0410'
  AND NOT EXISTS (
      SELECT 1 FROM prisoner_activities pa
      WHERE pa.prisoner_id = p.id
        AND pa.staff_user_id = s.id
        AND pa.activity_name = 'Court Transfer'
        AND pa.activity_date = '2026-04-15'
  );

-- -----------------------------------------------------------------------------
-- 8) Deleted prisoners archive (for trashed record)
-- -----------------------------------------------------------------------------
INSERT INTO deleted_prisoners (prisoner_id, deleted_by, reason)
SELECT p.id, a.id, 'Record moved to trash for archival demonstration.'
FROM prisoners p
JOIN users a ON a.email = 'admin.kathmandu@pms.gov.np'
WHERE p.prisoner_id = 'NP-PMS-0609'
  AND NOT EXISTS (
      SELECT 1 FROM deleted_prisoners dp WHERE dp.prisoner_id = p.id
  );

-- -----------------------------------------------------------------------------
-- 9) Login attempts
-- -----------------------------------------------------------------------------
INSERT INTO login_attempts (user_id, email, success, ip_address)
SELECT u.id, u.email, 1, '192.168.1.10'
FROM users u
WHERE u.email = 'admin.kathmandu@pms.gov.np'
  AND NOT EXISTS (
      SELECT 1 FROM login_attempts la
      WHERE la.email = u.email AND la.success = 1 AND la.ip_address = '192.168.1.10'
  );

INSERT INTO login_attempts (user_id, email, success, ip_address)
SELECT u.id, u.email, 0, '192.168.1.41'
FROM users u
WHERE u.email = 'ram.gurung.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM login_attempts la
      WHERE la.email = u.email AND la.success = 0 AND la.ip_address = '192.168.1.41'
  );

INSERT INTO login_attempts (user_id, email, success, ip_address)
SELECT u.id, u.email, 1, '192.168.1.41'
FROM users u
WHERE u.email = 'ram.gurung.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM login_attempts la
      WHERE la.email = u.email AND la.success = 1 AND la.ip_address = '192.168.1.41'
  );

-- -----------------------------------------------------------------------------
-- 10) Notifications
-- -----------------------------------------------------------------------------
INSERT INTO notifications (user_id, title, message, is_read)
SELECT u.id, 'Visit Approved', 'Your visit request for Ramesh Karki on 2026-04-19 was approved.', 0
FROM users u
WHERE u.email = 'sita.thapa.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM notifications n
      WHERE n.user_id = u.id AND n.title = 'Visit Approved'
  );

INSERT INTO notifications (user_id, title, message, is_read)
SELECT u.id, 'New Inquiry Received', 'A family inquiry requires review and response.', 0
FROM users u
WHERE u.email = 'admin.kathmandu@pms.gov.np'
  AND NOT EXISTS (
      SELECT 1 FROM notifications n
      WHERE n.user_id = u.id AND n.title = 'New Inquiry Received'
  );

INSERT INTO notifications (user_id, title, message, is_read)
SELECT u.id, 'Request Pending', 'Your visit request is currently pending approval.', 1
FROM users u
WHERE u.email = 'ram.gurung.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM notifications n
      WHERE n.user_id = u.id AND n.title = 'Request Pending'
  );

-- -----------------------------------------------------------------------------
-- 11) Inquiries
-- -----------------------------------------------------------------------------
INSERT INTO inquiries (family_member_id, subject, message, response, responded_at)
SELECT fm.id,
       'Medical status update request',
       'Please provide the latest health update for the prisoner after recent checkup.',
       'Health condition is stable. Routine medication is ongoing under prison medical team supervision.',
       NOW()
FROM family_members fm
JOIN users u ON u.id = fm.user_id
WHERE u.email = 'sita.thapa.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM inquiries i
      WHERE i.family_member_id = fm.id
        AND i.subject = 'Medical status update request'
  );

INSERT INTO inquiries (family_member_id, subject, message)
SELECT fm.id,
       'Next available visit slot',
       'Please confirm the next available visit slot for the last week of April.'
FROM family_members fm
JOIN users u ON u.id = fm.user_id
WHERE u.email = 'ram.gurung.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM inquiries i
      WHERE i.family_member_id = fm.id
        AND i.subject = 'Next available visit slot'
  );

-- -----------------------------------------------------------------------------
-- 12) Activity logs
-- -----------------------------------------------------------------------------
INSERT INTO activity_logs (user_id, action, details)
SELECT u.id, 'LOGIN_SUCCESS', 'Admin login successful from Kathmandu HQ network.'
FROM users u
WHERE u.email = 'admin.kathmandu@pms.gov.np'
  AND NOT EXISTS (
      SELECT 1 FROM activity_logs al
      WHERE al.user_id = u.id AND al.action = 'LOGIN_SUCCESS'
  );

INSERT INTO activity_logs (user_id, action, details)
SELECT u.id, 'VISIT_REQUEST_APPROVED', 'Approved visit for NP-PMS-0142 scheduled on 2026-04-19 at 10:30.'
FROM users u
WHERE u.email = 'nabin.karki@pms.gov.np'
  AND NOT EXISTS (
      SELECT 1 FROM activity_logs al
      WHERE al.user_id = u.id AND al.action = 'VISIT_REQUEST_APPROVED'
  );

INSERT INTO activity_logs (user_id, action, details)
SELECT u.id, 'INQUIRY_SUBMITTED', 'Family inquiry submitted for medical update.'
FROM users u
WHERE u.email = 'sita.thapa.family@gmail.com'
  AND NOT EXISTS (
      SELECT 1 FROM activity_logs al
      WHERE al.user_id = u.id AND al.action = 'INQUIRY_SUBMITTED'
  );
