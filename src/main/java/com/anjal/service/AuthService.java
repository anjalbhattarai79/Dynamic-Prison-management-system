package com.anjal.service;

import java.sql.SQLException;

import com.anjal.dao.UserDAO;
import com.anjal.model.User;
import com.anjal.util.PasswordUtil;
import com.anjal.util.ValidationUtil;

/**
 * Authentication service for database-backed login.
 */
public class AuthService {

	private final UserDAO userDAO = new UserDAO();

	public AuthResult authenticate(String email, String password, String ipAddress) {
		AuthResult result = new AuthResult();

		String normalizedEmail = email == null ? "" : email.trim();

		if (!ValidationUtil.isValidEmail(normalizedEmail) || !ValidationUtil.isNotEmpty(password)) {
			result.setSuccess(false);
			result.setMessage("Invalid email or password format.");
			return result;
		}

		try {
			User user = userDAO.findByEmail(normalizedEmail);
			if (user == null) {
				userDAO.recordLoginAttempt(null, normalizedEmail, false, ipAddress);
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
				userDAO.recordLoginAttempt(user.getId(), normalizedEmail, false, ipAddress);
				userDAO.evaluateAndLockAccountIfNeeded(user);
				result.setSuccess(false);
				result.setMessage("Invalid credentials.");
				return result;
			}

			userDAO.recordLoginAttempt(user.getId(), normalizedEmail, true, ipAddress);
			result.setSuccess(true);
			result.setUser(user);
			result.setMessage("Login successful.");
			return result;
		} catch (SQLException e) {
			result.setSuccess(false);
			result.setMessage("Database error while authenticating. Please try again later.");
			return result;
		}
	}

	public RegistrationResult registerFamily(String fullName, String email, String password, String confirmPassword) {
		RegistrationResult result = new RegistrationResult();
		result.setSuccess(false);
		result.setMessage("Registration is disabled in the current admin-only test mode.");
		return result;
	}

	public PasswordResetInitResult initiatePasswordReset(String email) {
		PasswordResetInitResult result = new PasswordResetInitResult();
		result.setSuccess(false);
		result.setMessage("Password reset is disabled until MySQL is enabled.");
		return result;
	}

	public BasicResult resetPassword(String email, String token, String newPassword, String confirmPassword) {
		BasicResult result = new BasicResult();
		result.setSuccess(false);
		result.setMessage("Password reset is disabled until MySQL is enabled.");
		return result;
	}

	/** Simple wrapper class for login result to keep controller clean. */
	public static class AuthResult {
		private boolean success;
		private String message;
		private User user;

		public boolean isSuccess() {
			return success;
		}

		public void setSuccess(boolean success) {
			this.success = success;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}

		public User getUser() {
			return user;
		}

		public void setUser(User user) {
			this.user = user;
		}
	}

	/** Result wrapper for registration. */
	public static class RegistrationResult {
		private boolean success;
		private String message;
		private User user;

		public boolean isSuccess() {
			return success;
		}

		public void setSuccess(boolean success) {
			this.success = success;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}

		public User getUser() {
			return user;
		}

		public void setUser(User user) {
			this.user = user;
		}
	}

	/** Basic success/message result used for reset password. */
	public static class BasicResult {
		private boolean success;
		private String message;

		public boolean isSuccess() {
			return success;
		}

		public void setSuccess(boolean success) {
			this.success = success;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}
	}

	/**
	 * Result for password reset initiation which also returns the token for demo.
	 */
	public static class PasswordResetInitResult extends BasicResult {
		private String token;

		public String getToken() {
			return token;
		}

		public void setToken(String token) {
			this.token = token;
		}
	}
}
