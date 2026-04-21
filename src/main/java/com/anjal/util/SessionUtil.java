package com.anjal.util;

import com.anjal.model.User;

import jakarta.servlet.http.HttpSession;

public class SessionUtil {

	private static final String USER_SESSION_KEY = "loggedInUser";

	public static void setLoggedInUser(HttpSession session, User user) {
		if (session == null) {
			return;
		}
		session.setAttribute(USER_SESSION_KEY, user);
		session.setAttribute("userId", user != null ? user.getId() : null);
		session.setAttribute("fullName", user != null ? user.getFullName() : null);
		session.setAttribute("role", user != null && user.getRole() != null ? user.getRole().getName() : null);
		session.setAttribute("adminName", user != null ? user.getFullName() : null);
	}

	public static User getLoggedInUser(HttpSession session) {
		if (session == null) {
			return null;
		}
		Object obj = session.getAttribute(USER_SESSION_KEY);
		if (obj instanceof User) {
			return (User) obj;
		}
		return null;
	}

	public static void invalidateSession(HttpSession session) {
		if (session != null) {
			session.invalidate();
		}
	}
}
