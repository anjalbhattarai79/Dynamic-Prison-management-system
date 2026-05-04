# Database Data Dictionary - Prison Management System

This document provides the exact schema and data dictionary for the `prison_management_db` as implemented in the Java source code and Data Access Objects (DAOs).

### 1. Table: `roles`
Stores the access levels for the system.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Auto-incrementing unique identifier. |
| `name` | VARCHAR(50) | NO | | Role name: 'ADMIN', 'STAFF', or 'FAMILY'. |

### 2. Table: `users`
Core table for all accounts (Admin, Staff, and Family).
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Auto-incrementing unique identifier. |
| `role_id` | INT | NO | FK | Reference to `roles(id)`. |
| `full_name` | VARCHAR(100)| NO | | User's full name. |
| `email` | VARCHAR(100)| NO | UNI | Login identifier (Email or Prisoner ID). |
| `password_hash`| VARCHAR(255)| NO | | PBKDF2 hashed password. |
| `password_salt`| VARCHAR(100)| NO | | Random salt used for hashing. |
| `is_locked` | BOOLEAN | NO | | 1 if account is locked, 0 otherwise. |
| `reset_token` | VARCHAR(100)| YES | | Token for password recovery. |
| `reset_token_expiry`| TIMESTAMP| YES | | Expiration time for reset token. |
| `created_at` | TIMESTAMP | NO | | Registration timestamp. |

### 3. Table: `prisoners`
Main repository for prisoner records.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Auto-incrementing internal ID. |
| `prisoner_id` | VARCHAR(20) | NO | UNI | Unique public ID (e.g., NP-PMS-0001). |
| `full_name` | VARCHAR(100)| NO | | Full name of the prisoner. |
| `date_of_birth`| DATE | NO | | Prisoner's date of birth. |
| `gender` | VARCHAR(10) | NO | | Gender (Male/Female/Other). |
| `crime_type` | VARCHAR(100)| NO | | Nature of the crime committed. |
| `sentence_years`| INT | NO | | Total years of imprisonment. |
| `admission_date`| DATE | NO | | Date of entry into prison. |
| `release_date` | DATE | YES | | Calculated or expected release date. |
| `block_number` | VARCHAR(20) | NO | | Cell block assignment. |
| `security_level`| VARCHAR(20) | NO | | High, Medium, or Low. |
| `status` | VARCHAR(20) | NO | | Active, Released, Transferred. |
| `is_deleted` | BOOLEAN | NO | | 1 for Trash (soft deleted), 0 for live. |

### 4. Table: `family_members`
Links users with the 'FAMILY' role to specific prisoners.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Unique identifier. |
| `user_id` | INT | NO | FK | Reference to `users(id)`. |
| `prisoner_id` | INT | NO | FK | Reference to `prisoners(id)`. |
| `relation` | VARCHAR(50) | NO | | Relationship (e.g., Mother, Brother). |
| `phone` | VARCHAR(20) | YES | | Contact number. |

### 5. Table: `visit_requests`
Stores visit applications submitted by family members.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Unique identifier. |
| `prisoner_id` | INT | NO | FK | The prisoner being visited. |
| `family_member_id`| INT | NO | FK | The person requesting the visit. |
| `preferred_visit_date`| DATE | NO | | Requested date for visit. |
| `status` | VARCHAR(20) | NO | | PENDING, APPROVED, REJECTED. |
| `created_at` | TIMESTAMP | NO | | Request submission timestamp. |

### 6. Table: `activity_logs`
Audit trail for the Admin Dashboard.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Unique identifier. |
| `user_id` | INT | YES | FK | User who performed the action. |
| `action` | VARCHAR(255)| NO | | Type of action (e.g., PRISONER_ADDED). |
| `details` | TEXT | YES | | Descriptive details of the event. |
| `created_at` | TIMESTAMP | NO | | Event occurrence timestamp. |

### 7. Table: `login_attempts`
Security table for brute-force protection.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Unique identifier. |
| `email` | VARCHAR(255)| NO | | Identifier used during attempt. |
| `success` | BOOLEAN | NO | | 1 for success, 0 for failure. |
| `ip_address` | VARCHAR(45) | NO | | Visitor IP (IPv4 or IPv6). |
| `attempt_time` | TIMESTAMP | NO | | Timestamp of the attempt. |

### 8. Table: `notifications`
Communication channel for the Family Portal.
| Column | Type | Nullable | Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | INT | NO | PK | Unique identifier. |
| `user_id` | INT | NO | FK | Target recipient. |
| `title` | VARCHAR(255)| YES | | Notification subject. |
| `message` | TEXT | NO | | Notification body content. |
| `is_read` | BOOLEAN | NO | | 0 for new, 1 for viewed. |
