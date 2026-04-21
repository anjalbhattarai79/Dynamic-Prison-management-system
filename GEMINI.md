# Prison Management System (PMS) - Gemini Context

This project is a Java-based Web Application designed to manage prison operations and provide a portal for family members of prisoners.

## Project Overview

*   **Purpose**: To streamline prisoner record management, staff coordination, and family interaction (visits/inquiries).
*   **Target Users**: Prison Administrators, Staff members, and Family members of prisoners.
*   **Key Modules**:
    *   **Admin Dashboard**: Management of prisoners, staff, and system-wide activity logs.
    *   **Family Portal**: Allows family members to request visits, check prisoner status, and communicate via inquiries.
    *   **Authentication & Authorization**: Role-based access control (ADMIN, STAFF, FAMILY) with session-based security.

## Technology Stack

*   **Backend**: Java (Jakarta Servlet 6.0, JSP).
*   **Database**: MySQL (using JDBC for connectivity).
*   **Frontend**: JSP, Vanilla CSS, Plain JavaScript.
*   **Server**: Compatible with Jakarta EE compatible containers (e.g., Apache Tomcat 10+).
*   **Architecture**: Classic MVC-like separation:
    *   `com.anjal.controller`: Servlets handling HTTP requests.
    *   `com.anjal.model`: Plain Old Java Objects (POJOs) representing domain entities.
    *   `com.anjal.dao`: Data Access Objects for database interactions.
    *   `com.anjal.service`: Business logic layer.
    *   `com.anjal.util`: Utility classes (DB connection, password hashing, validation, session management).

## Building and Running

### Prerequisites
*   JDK 17 or higher.
*   Apache Tomcat 10+ (for Jakarta EE 10 support).
*   MySQL Server.
*   Eclipse IDE (Dynamic Web Project support) or a compatible build environment.

### Database Setup
1.  Create a database named `prison_management_db`.
2.  Execute `schema.sql` to create the table structure.
3.  (Optional) Run migrations in `migrations/` to seed sample data (e.g., `20260417_seed_nepal_sample_data.sql`).
4.  Update database credentials in `src/main/java/com/anjal/util/DBConnection.java`.

### Running the Application
1.  Import the project into Eclipse as an "Existing Project into Workspace".
2.  Add a Server (e.g., Tomcat 10) in Eclipse.
3.  Add the project to the server and start it.
4.  Access via `http://localhost:8080/Prison-Management-System/`.

### Default Credentials (Development)
*   **Admin Email**: `admin@example.com`
*   **Password**: `Admin@123`

## Development Conventions

*   **Surgical Updates**: Prefer small, targeted changes to existing classes.
*   **Security**: Never expose raw passwords. Use `PasswordUtil` for hashing and verification.
*   **Validation**: Use `ValidationUtil` for consistent input checking.
*   **Error Handling**: Controllers should use `returnWithError` patterns to provide feedback to JSP views.
*   **Styling**: Follow the established CSS themes in `src/main/webapp/css/`.
