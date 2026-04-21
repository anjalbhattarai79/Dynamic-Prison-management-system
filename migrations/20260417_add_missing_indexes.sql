-- Migration: add missing indexes for DB-backed mode
-- Safe to run multiple times on MySQL 5.7+ and 8+

USE prison_management_db;

DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER //
CREATE PROCEDURE add_index_if_missing(
	IN p_table_name VARCHAR(64),
	IN p_index_name VARCHAR(64),
	IN p_create_sql VARCHAR(255)
)
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM information_schema.statistics
		WHERE table_schema = DATABASE()
		  AND table_name = p_table_name
		  AND index_name = p_index_name
	) THEN
		SET @sql_stmt = p_create_sql;
		PREPARE stmt FROM @sql_stmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
END //
DELIMITER ;

-- users
CALL add_index_if_missing('users', 'idx_users_role_id', 'CREATE INDEX idx_users_role_id ON users(role_id)');
CALL add_index_if_missing('users', 'idx_users_reset_token', 'CREATE INDEX idx_users_reset_token ON users(reset_token)');
CALL add_index_if_missing('users', 'idx_users_reset_token_expiry', 'CREATE INDEX idx_users_reset_token_expiry ON users(reset_token_expiry)');

-- prisoners
CALL add_index_if_missing('prisoners', 'idx_prisoners_status', 'CREATE INDEX idx_prisoners_status ON prisoners(status)');
CALL add_index_if_missing('prisoners', 'idx_prisoners_block_number', 'CREATE INDEX idx_prisoners_block_number ON prisoners(block_number)');
CALL add_index_if_missing('prisoners', 'idx_prisoners_security_level', 'CREATE INDEX idx_prisoners_security_level ON prisoners(security_level)');
CALL add_index_if_missing('prisoners', 'idx_prisoners_is_deleted', 'CREATE INDEX idx_prisoners_is_deleted ON prisoners(is_deleted)');

-- family_members
CALL add_index_if_missing('family_members', 'idx_family_members_user_id', 'CREATE INDEX idx_family_members_user_id ON family_members(user_id)');
CALL add_index_if_missing('family_members', 'idx_family_members_prisoner_id', 'CREATE INDEX idx_family_members_prisoner_id ON family_members(prisoner_id)');

-- visit_requests
CALL add_index_if_missing('visit_requests', 'idx_visit_requests_prisoner_id', 'CREATE INDEX idx_visit_requests_prisoner_id ON visit_requests(prisoner_id)');
CALL add_index_if_missing('visit_requests', 'idx_visit_requests_family_member_id', 'CREATE INDEX idx_visit_requests_family_member_id ON visit_requests(family_member_id)');
CALL add_index_if_missing('visit_requests', 'idx_visit_requests_status', 'CREATE INDEX idx_visit_requests_status ON visit_requests(status)');
CALL add_index_if_missing('visit_requests', 'idx_visit_requests_preferred_visit_date', 'CREATE INDEX idx_visit_requests_preferred_visit_date ON visit_requests(preferred_visit_date)');

-- visit_schedule
CALL add_index_if_missing('visit_schedule', 'idx_visit_schedule_visit_request_id', 'CREATE INDEX idx_visit_schedule_visit_request_id ON visit_schedule(visit_request_id)');
CALL add_index_if_missing('visit_schedule', 'idx_visit_schedule_scheduled_date', 'CREATE INDEX idx_visit_schedule_scheduled_date ON visit_schedule(scheduled_date)');

-- prisoner_activities
CALL add_index_if_missing('prisoner_activities', 'idx_prisoner_activities_prisoner_id', 'CREATE INDEX idx_prisoner_activities_prisoner_id ON prisoner_activities(prisoner_id)');
CALL add_index_if_missing('prisoner_activities', 'idx_prisoner_activities_activity_date', 'CREATE INDEX idx_prisoner_activities_activity_date ON prisoner_activities(activity_date)');

-- deleted_prisoners
CALL add_index_if_missing('deleted_prisoners', 'idx_deleted_prisoners_prisoner_id', 'CREATE INDEX idx_deleted_prisoners_prisoner_id ON deleted_prisoners(prisoner_id)');
CALL add_index_if_missing('deleted_prisoners', 'idx_deleted_prisoners_deleted_at', 'CREATE INDEX idx_deleted_prisoners_deleted_at ON deleted_prisoners(deleted_at)');

-- login_attempts
CALL add_index_if_missing('login_attempts', 'idx_login_attempts_user_id', 'CREATE INDEX idx_login_attempts_user_id ON login_attempts(user_id)');
CALL add_index_if_missing('login_attempts', 'idx_login_attempts_email', 'CREATE INDEX idx_login_attempts_email ON login_attempts(email)');
CALL add_index_if_missing('login_attempts', 'idx_login_attempts_attempt_time', 'CREATE INDEX idx_login_attempts_attempt_time ON login_attempts(attempt_time)');

-- notifications
CALL add_index_if_missing('notifications', 'idx_notifications_user_id', 'CREATE INDEX idx_notifications_user_id ON notifications(user_id)');
CALL add_index_if_missing('notifications', 'idx_notifications_is_read', 'CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
CALL add_index_if_missing('notifications', 'idx_notifications_created_at', 'CREATE INDEX idx_notifications_created_at ON notifications(created_at)');

-- inquiries
CALL add_index_if_missing('inquiries', 'idx_inquiries_family_member_id', 'CREATE INDEX idx_inquiries_family_member_id ON inquiries(family_member_id)');
CALL add_index_if_missing('inquiries', 'idx_inquiries_created_at', 'CREATE INDEX idx_inquiries_created_at ON inquiries(created_at)');

-- activity_logs
CALL add_index_if_missing('activity_logs', 'idx_activity_logs_user_id', 'CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id)');
CALL add_index_if_missing('activity_logs', 'idx_activity_logs_created_at', 'CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at)');

DROP PROCEDURE IF EXISTS add_index_if_missing;
