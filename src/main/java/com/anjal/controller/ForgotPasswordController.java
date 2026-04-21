package com.anjal.controller;

import java.io.IOException;

import com.anjal.service.AuthService;
import com.anjal.service.AuthService.PasswordResetInitResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles the "forgot password" flow.
 */
@WebServlet("/forgot-password")
public class ForgotPasswordController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final AuthService authService = new AuthService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String email = request.getParameter("email");
		PasswordResetInitResult result = authService.initiatePasswordReset(email);
		request.setAttribute(result.isSuccess() ? "successMsg" : "errorMsg", result.getMessage());
		request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
	}
}
