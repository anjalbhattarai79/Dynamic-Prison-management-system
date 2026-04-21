package com.anjal.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Family Profile Controller
 * 
 * Responsibilities: - Handle /family-profile requests - Display and manage
 * family member profile - Forward to family profile JSP
 */
@WebServlet("/family-profile")
public class FamilyProfileController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String familyName = "Sarita Karki";
		request.setAttribute("familyName", familyName);
		request.getRequestDispatcher("/WEB-INF/pages/family-profile.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String fullName = request.getParameter("fullName");
		String phone = request.getParameter("phone");
		String email = request.getParameter("email");
		String relation = request.getParameter("relation");
		String address = request.getParameter("address");

		request.setAttribute("familyName", fullName != null ? fullName : "Sarita Karki");
		request.setAttribute("submittedPhone", phone);
		request.setAttribute("submittedEmail", email);

		request.getRequestDispatcher("/WEB-INF/pages/family-profile.jsp").forward(request, response);
	}
}
