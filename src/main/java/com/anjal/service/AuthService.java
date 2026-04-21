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
			e.printStackTrace();
			result.setSuccess(false);
			result.setMessage("Database error while authenticating. Please try again later.");
			return result;
		}
	}

	public RegistrationResult registerFamily(String fullName, String email, String password, String confirmPassword) {
		RegistrationResult result = new RegistrationResult();

		if (!ValidationUtil.isValidFullName(fullName) || !ValidationUtil.isValidEmail(email)
				|| !ValidationUtil.isNotEmpty(password)) {
			result.setSuccess(false);
			result.setMessage("Please provide all fields correctly.");
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

			User newUser = userDAO.createFamilyUser(fullName, email, hash, salt);
			if (newUser != null) {
				result.setSuccess(true);
				result.setUser(newUser);
				result.setMessage("Registration successful.");
			} else {
				result.setSuccess(false);
				result.setMessage("Error creating account.");
			}
		} catch (SQLException e) {
			result.setSuccess(false);
			result.setMessage("Database error during registration.");
		}
		return result;
	}

	public PasswordResetInitResult initiatePasswordReset(String email) {
		PasswordResetInitResult result = new PasswordResetInitResult();
		if (!ValidationUtil.isValidEmail(email)) {
			result.setSuccess(false);
			result.setMessage("Invalid email format.");
			return result;
		}

		try {
			String token = userDAO.createPasswordResetToken(email);
			if (token != null) {
				result.setSuccess(true);
				result.setToken(token);
				result.setMessage("If this email exists, a reset token has been generated.");
			} else {
				result.setSuccess(false);
				result.setMessage("If this email exists, a reset token has been generated.");
			}
		} catch (SQLException e) {
			result.setSuccess(false);
			result.setMessage("Database error while initiating reset.");
		}
		return result;
	}

	public BasicResult resetPassword(String email, String token, String newPassword, String confirmPassword) {
		BasicResult result = new BasicResult();

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
			result.setMessage("Password has been successfully updated.");
		} catch (SQLException e) {
			result.setSuccess(false);
			result.setMessage("Database error during password reset.");
		}
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
