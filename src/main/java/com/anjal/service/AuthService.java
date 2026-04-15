package com.anjal.service;

import java.sql.SQLException;

import com.anjal.dao.UserDAO;
import com.anjal.model.User;
import com.anjal.util.PasswordUtil;
import com.anjal.util.ValidationUtil;

/**
 * Service layer for authentication-related business logic.
 */
public class AuthService {

    private final UserDAO userDAO = new UserDAO();

    public AuthResult authenticate(String email, String password, String ipAddress) {
        AuthResult result = new AuthResult();

        if (!ValidationUtil.isValidEmail(email) || !ValidationUtil.isNotEmpty(password)) {
            result.setSuccess(false);
            result.setMessage("Invalid email or password format.");
            return result;
        }

        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                userDAO.recordLoginAttempt(null, email, false, ipAddress);
                result.setSuccess(false);
                result.setMessage("Invalid credentials.");
                return result;
            }

            if (user.isLocked()) {
                result.setSuccess(false);
                result.setMessage("Your account is locked due to multiple failed attempts.");
                return result;
            }

            boolean passwordValid = PasswordUtil.verifyPassword(password, user.getPasswordSalt(), user.getPasswordHash());
            if (!passwordValid) {
                userDAO.recordLoginAttempt(user.getId(), email, false, ipAddress);
                userDAO.evaluateAndLockAccountIfNeeded(user);
                result.setSuccess(false);
                result.setMessage("Invalid credentials.");
                return result;
            }

            userDAO.recordLoginAttempt(user.getId(), email, true, ipAddress);
            result.setSuccess(true);
            result.setUser(user);
            return result;
        } catch (SQLException e) {
            result.setSuccess(false);
            result.setMessage("Error while authenticating. Please try again later.");
            return result;
        }
    }

    public RegistrationResult registerFamily(String fullName, String email, String password, String confirmPassword) {
        RegistrationResult result = new RegistrationResult();

        if (!ValidationUtil.isValidFullName(fullName)) {
            result.setSuccess(false);
            result.setMessage("Full name must contain only letters and spaces.");
            return result;
        }
        if (!ValidationUtil.isValidEmail(email)) {
            result.setSuccess(false);
            result.setMessage("Please enter a valid email address.");
            return result;
        }
        if (!ValidationUtil.isNotEmpty(password) || password.length() < 6) {
            result.setSuccess(false);
            result.setMessage("Password must be at least 6 characters long.");
            return result;
        }
        if (!password.equals(confirmPassword)) {
            result.setSuccess(false);
            result.setMessage("Passwords do not match.");
            return result;
        }

        try {
            if (userDAO.emailExists(email)) {
                result.setSuccess(false);
                result.setMessage("Email is already registered.");
                return result;
            }
            String salt = PasswordUtil.generateSalt();
            String hash = PasswordUtil.hashPassword(password, salt);
            User user = userDAO.createFamilyUser(fullName, email, hash, salt);
            if (user == null) {
                result.setSuccess(false);
                result.setMessage("Unable to create account. Please try again.");
                return result;
            }
            result.setSuccess(true);
            result.setUser(user);
            return result;
        } catch (SQLException e) {
            result.setSuccess(false);
            result.setMessage("Error while registering. Please try again later.");
            return result;
        }
    }

    public PasswordResetInitResult initiatePasswordReset(String email) {
        PasswordResetInitResult result = new PasswordResetInitResult();
        if (!ValidationUtil.isValidEmail(email)) {
            result.setSuccess(false);
            result.setMessage("Please enter a valid email address.");
            return result;
        }
        try {
            String token = userDAO.createPasswordResetToken(email);
            if (token == null) {
                result.setSuccess(false);
                result.setMessage("No account found with this email.");
                return result;
            }
            // In a production system this token would be emailed.
            result.setSuccess(true);
            result.setToken(token);
            result.setMessage("Password reset token generated. (In a real system this would be emailed.)");
            return result;
        } catch (SQLException e) {
            result.setSuccess(false);
            result.setMessage("Error while generating reset token.");
            return result;
        }
    }

    public BasicResult resetPassword(String email, String token, String newPassword, String confirmPassword) {
        BasicResult result = new BasicResult();
        if (!ValidationUtil.isValidEmail(email)) {
            result.setSuccess(false);
            result.setMessage("Invalid email.");
            return result;
        }
        if (!ValidationUtil.isNotEmpty(token)) {
            result.setSuccess(false);
            result.setMessage("Reset token is required.");
            return result;
        }
        if (!ValidationUtil.isNotEmpty(newPassword) || newPassword.length() < 6) {
            result.setSuccess(false);
            result.setMessage("Password must be at least 6 characters long.");
            return result;
        }
        if (!newPassword.equals(confirmPassword)) {
            result.setSuccess(false);
            result.setMessage("Passwords do not match.");
            return result;
        }
        try {
            User user = userDAO.findByEmailAndValidToken(email, token);
            if (user == null) {
                result.setSuccess(false);
                result.setMessage("Invalid or expired reset token.");
                return result;
            }
            String salt = PasswordUtil.generateSalt();
            String hash = PasswordUtil.hashPassword(newPassword, salt);
            userDAO.updatePassword(user.getId(), hash, salt);
            result.setSuccess(true);
            result.setMessage("Password updated successfully. You can now log in.");
            return result;
        } catch (SQLException e) {
            result.setSuccess(false);
            result.setMessage("Error while resetting password.");
            return result;
        }
    }

    /** Simple wrapper class for login result to keep controller clean. */
    public static class AuthResult {
        private boolean success;
        private String message;
        private User user;
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public User getUser() { return user; }
        public void setUser(User user) { this.user = user; }
    }

    /** Result wrapper for registration. */
    public static class RegistrationResult {
        private boolean success;
        private String message;
        private User user;
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public User getUser() { return user; }
        public void setUser(User user) { this.user = user; }
    }

    /** Basic success/message result used for reset password. */
    public static class BasicResult {
        private boolean success;
        private String message;
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }

    /** Result for password reset initiation which also returns the token for demo. */
    public static class PasswordResetInitResult extends BasicResult {
        private String token;
        public String getToken() { return token; }
        public void setToken(String token) { this.token = token; }
    }
}
