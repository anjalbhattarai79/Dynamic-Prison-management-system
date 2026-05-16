package com.anjal.controller;

import java.io.IOException;

import com.anjal.model.User;
import com.anjal.service.AuthService;
import com.anjal.service.AuthService.AuthResult;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/login")
public class LoginController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final AuthService authService = new AuthService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// If already logged in, skip the login page
		User loggedIn = SessionUtil.getLoggedInUser(request.getSession(false));
		if (loggedIn != null) {
			response.sendRedirect(request.getContextPath() + resolveDashboardByRole(loggedIn));
			return;
		}

		request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String email = request.getParameter("email");
		String password = request.getParameter("password");
		String loginType = request.getParameter("loginType");
		String ipAddress = request.getRemoteAddr();

		// 1. Validate Input
		if (loginType == null || loginType.trim().isEmpty()) {
			returnWithError(request, response, "Please choose a login type.", email, loginType);
			return;
		}

		// 2. Authenticate Credentials
		AuthResult result = authService.authenticate(email, password, ipAddress, loginType);
		if (!result.isSuccess()) {
			returnWithError(request, response, result.getMessage(), email, loginType);
			return;
		}

		User authUser = result.getUser();
		String actualRole = (authUser != null && authUser.getRole() != null) ? authUser.getRole().getName() : "";

		// 3. Role-Type Stability Check
		if (!matchesLoginType(loginType, actualRole)) {
			returnWithError(request, response, "Access Denied: Your account role does not match the selected portal.",
					email, loginType);
			return;
		}

		// 4. Success - Establish Session
		SessionUtil.setLoggedInUser(request.getSession(true), authUser);

		// Auto-link logic for Family users using Prisoner ID as email
		if ("FAMILY".equalsIgnoreCase(authUser.getRole().getName())) {
			com.anjal.dao.FamilyDAO familyDAO = new com.anjal.dao.FamilyDAO();
			try {
				com.anjal.model.FamilyMember existing = familyDAO.getFamilyMemberByUserId(authUser.getId());
				if (existing == null) {
					com.anjal.dao.PrisonerDAO prisonerDAO = new com.anjal.dao.PrisonerDAO();
					com.anjal.model.Prisoner p = prisonerDAO.findByPrisonerId(authUser.getEmail());
					if (p != null) {
						familyDAO.createDefaultFamilyMember(authUser.getId(), p.getId(), "Family");
					}
				}
			} catch (java.sql.SQLException e) {
				e.printStackTrace();
			}
		}

		response.sendRedirect(request.getContextPath() + resolveDashboardByRole(authUser));
	}

	private void returnWithError(HttpServletRequest req, HttpServletResponse resp, String error, String email,
			String type) throws ServletException, IOException {
		req.setAttribute("error", error);
		req.setAttribute("email", email);
		req.setAttribute("loginType", type);
		req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
	}

	private boolean matchesLoginType(String loginType, String actualRole) {
		if ("ADMIN".equalsIgnoreCase(loginType)) {
			return "ADMIN".equalsIgnoreCase(actualRole) || "STAFF".equalsIgnoreCase(actualRole);
		}
		return "FAMILY".equalsIgnoreCase(loginType) && "FAMILY".equalsIgnoreCase(actualRole);
	}

	private String resolveDashboardByRole(User user) {
		if (user == null || user.getRole() == null)
			return "/login";
		String role = user.getRole().getName();

		if ("ADMIN".equalsIgnoreCase(role) || "STAFF".equalsIgnoreCase(role))
			return "/admin-dashboard";
		if ("FAMILY".equalsIgnoreCase(role))
			return "/family-dashboard";

		return "/unauthorized";
	}
}