# Secure Prison Management and Family Portal System – Project Overview

## 1. Project Summary

This project is an academic Java EE (Jakarta EE-style) web application called **Secure Prison Management and Family Portal System**. It is intended as a coursework-style prison management system that runs on a traditional JSP/Servlet stack with MySQL and JDBC, following a simple **Model–View–Controller (MVC)** architecture.

The system is designed to support three main roles:
- **Admin** – manages prisoners, staff, families, system logs, and trash/restore.
- **Staff** – manages daily prisoner details, activities, and visit requests.
- **Family Member** – accesses limited prisoner information, requests visits, and manages their own profile.

At the moment, the implementation in this workspace is in an **early skeleton state** (one controller, one JSP, and one CSS file stub). The detailed requirements and target architecture are described in [Master Prompt.md](Master%20Prompt.md).

## 2. Current Code Structure

Root-level files and folders:
- **.gitignore** – ignores environment files, build outputs, IDE metadata, and OS cruft.
- **.project, .classpath, .settings/** – Eclipse project metadata.
- **build/** – build output directory created by the IDE/build process.
- **src/** – main application source code.
- **Master Prompt.md** – a detailed specification of the intended coursework project (acts as the main requirements document).

### 2.1 Java Packages

Located under `src/main/java`:

- **com.anjal.controller**
  - `LoginController.java`
    - A basic `HttpServlet` annotated with `@WebServlet("/login")`.
    - Currently responds to GET requests with a plain text string: `"Served at: <contextPath>"`.
    - `doPost` simply delegates to `doGet`.
    - There is a commented-out line indicating the intent to forward to a JSP: `/WEB-INF/pages/home.jsp`.

- **com.anjal.config**
  - Present as an empty package folder (no Java classes yet).

- **com.anjal.model**
  - Present as an empty package folder (no Java classes yet).

Planned (per requirements in Master Prompt):
- Packages like `com.pms.controller`, `com.pms.model`, `com.pms.dao`, `com.pms.service`, and `com.pms.util` are suggested in the prompt, but this actual project currently uses the base package **`com.anjal`** instead and only has `controller`, `config`, and `model` sub-packages.

### 2.2 Web Resources (JSP, CSS)

Located under `src/main/webapp`:

- **WEB-INF/pages/home.jsp**
  - A minimal JSP page with only the basic HTML skeleton and no dynamic content yet.
  - Intended to be a protected view (under `WEB-INF`) probably used as a post-login home/dashboard page.

- **css/home.css**
  - Exists but currently empty.
  - Intended for page styling (per coursework: CSS only, no frameworks like Bootstrap).

- **META-INF/MANIFEST.MF**
  - Standard metadata folder and manifest file for the web application.

## 3. Intended Functional Scope (from Master Prompt)

Based on [Master Prompt.md](Master%20Prompt.md), the final system is expected to include:

- **Authentication & Authorization**
  - Login via email/password using `HttpSession`.
  - Role-based access control for Admin, Staff, and Family.
  - Logout, forgot password, reset password.
  - Account locking after repeated failed attempts.

- **Admin Module**
  - Dashboard with counts (prisoners, staff, visit requests, etc.).
  - Manage prisoners (CRUD with soft delete + trash/restore).
  - Manage staff and family accounts.
  - View activity logs.

- **Staff Module**
  - Dashboard and prisoner views.
  - Update prisoner details.
  - Record activities.
  - Review and process visit requests.

- **Family Portal**
  - Registration and login.
  - Limited prisoner info view.
  - Submit and track visit requests.
  - Manage profile and inquiries.

- **Prisoner Management & Activities**
  - Full prisoner CRUD with soft delete.
  - Activity tracking (work, education, etc.).

- **Visit Management**
  - Visit requests and schedules, conceptual **Queue** usage for processing pending requests.

- **Data Structures Requirement**
  - Use **Queue** for visit request processing.
  - Use **Stack** for trash/restore or undo history.

- **Validation and Exception Handling**
  - Server-side validation for all forms.
  - Clean, user-friendly error messages.
  - Proper SQL exception handling.

- **Database Design (MySQL)**
  - Tables: `roles`, `users`, `prisoners`, `family_members`, `visit_requests`, `visit_schedule`, `prisoner_activities`, `deleted_prisoners`, `login_attempts`, `notifications`, `inquiries`, `activity_logs`.

- **Utilities**
  - `DBConnection`, `PasswordUtil`, `ValidationUtil`, `SessionUtil`, `AuthFilter`.

- **JSP Views**
  - Public pages: login, register, forgot/reset password, about, contact.
  - Role-specific dashboards and management pages for Admin, Staff, and Family.

Currently, none of these advanced features are implemented in code yet; they exist only in the requirements.

## 4. Current Implementation Status

- **Implemented**
  - Project skeleton as an Eclipse Dynamic Web Project / Java EE project.
  - Basic controller: `LoginController` servlet.
  - Basic JSP view: `home.jsp` with HTML boilerplate.
  - Empty CSS file for future styling.
  - Git configuration via `.gitignore` for build/IDE files.

- **Not Implemented Yet (High Level)**
  - All database schema and JDBC DAO classes.
  - All model/entity classes (prisoner, user, visit request, etc.).
  - Services and utilities (DB connection, validation, password hashing, sessions).
  - Authentication/authorization logic.
  - Role-based dashboards and full set of JSP pages.
  - Data-structure-based logic (Queue/Stack usage).
  - Logging, notifications, inquiries, and activity logs.

## 5. How to Use This Overview with an AI Assistant

When prompting an AI to continue building this project, provide:

1. This file (PROJECT_OVERVIEW.md) for a concise snapshot of the **current state**.
2. The detailed requirements in [Master Prompt.md](Master%20Prompt.md) for the **full target specification**.
3. Any specific step you want next, for example:
   - "Design the MySQL schema and provide `schema.sql` for this project."
   - "Generate Java model classes for all entities using package `com.anjal.model`."
   - "Implement `DBConnection` and DAO classes using JDBC and MySQL." 
   - "Create JSP login page and integrate it with `LoginController`."

This combination lets the AI understand both what exists now and what still needs to be built, while keeping changes consistent with the current package names and file layout in this repository.
