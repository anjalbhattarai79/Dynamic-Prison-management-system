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

/**
 * Handles login requests. Follows MVC: calls AuthService and forwards/redirects to JSP.
 */
@WebServlet("/login")
public class LoginController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final AuthService authService = new AuthService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// If already logged in, redirect to a simple home page.
		User loggedIn = SessionUtil.getLoggedInUser(request);
		if (loggedIn != null) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String email = request.getParameter("email");
		String password = request.getParameter("password");
		String ipAddress = request.getRemoteAddr();

		AuthResult result = authService.authenticate(email, password, ipAddress);
		if (!result.isSuccess()) {
			request.setAttribute("error", result.getMessage());
			request.setAttribute("email", email);
			request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
			return;
		}

		SessionUtil.setLoggedInUser(request, result.getUser());
		response.sendRedirect(request.getContextPath() + "/home");
	}
}
