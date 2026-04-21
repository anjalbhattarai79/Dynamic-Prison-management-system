package com.anjal.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/family-inquiry")
public class InquiryController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// Data for context
		request.setAttribute("supportEmail", "support.prison@pms.gov.np");
		request.setAttribute("officeHours", "Sun - Fri: 10:00 AM - 5:00 PM");

		request.getRequestDispatcher("/WEB-INF/pages/inquiry.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// Capture inquiry details
		String subject = request.getParameter("subject");
		String message = request.getParameter("message");

		System.out.println("Inquiry received: " + subject);

		// Redirect with a success message
		response.sendRedirect(request.getContextPath() + "/family-dashboard?msg=inquiry_sent");
	}
}