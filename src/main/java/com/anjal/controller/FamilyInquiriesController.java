package com.anjal.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * FamilyInquiriesController Servlet
 * 
 * Responsible for handling family member inquiries and support requests.
 * Manages the submission, tracking, and resolution of inquiries from family
 * members regarding their visits, inmates, or general information.
 */
@WebServlet("/family-inquiries")
public class FamilyInquiriesController extends HttpServlet {

	/**
	 * Handles GET requests to display inquiries
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String familyName = request.getParameter("familyName");
		if (familyName == null) {
			familyName = "Family";
		}

		request.setAttribute("familyName", familyName);
		request.getRequestDispatcher("/WEB-INF/pages/family-inquiries.jsp").forward(request, response);
	}

	/**
	 * Handles POST requests to submit inquiries
	 */
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String familyName = request.getParameter("familyName");
		String inquiryType = request.getParameter("inquiryType");
		String message = request.getParameter("message");

		if (familyName == null) {
			familyName = "Family";
		}

		// Process the inquiry (would typically save to database)
		request.setAttribute("familyName", familyName);
		request.setAttribute("inquiryType", inquiryType);
		request.setAttribute("message", message);

		request.getRequestDispatcher("/WEB-INF/pages/family-inquiries.jsp").forward(request, response);
	}
}
