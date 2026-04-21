package com.anjal.controller;

import java.io.IOException;
import java.util.List;

import com.anjal.service.DashboardService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Dashboard Controller
 * 
 * Responsibilities: - Check authentication - Check admin role - Load dashboard
 * data - Forward to admin dashboard JSP
 */
@WebServlet("/admin-dashboard")
public class AdminDashboardController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final DashboardService dashboardService = new DashboardService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// 1. Check if user is logged in
//		User loggedInUser = SessionUtil.getLoggedInUser(request);
//
//		if (loggedInUser == null) {
//			// Not logged in → redirect to login
//			response.sendRedirect(request.getContextPath() + "/login");
//			return;
//		}

//		// 2. Check if user is ADMIN
//		if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
//			// Not authorized → redirect to unauthorized page or home
//			response.sendRedirect(request.getContextPath() + "/unauthorized");
//			return;
//		}

		// 3. Load dashboard data
		int totalPrisoners = dashboardService.getTotalPrisoners();
		int activePrisoners = dashboardService.getSnapshot().getActivePrisoners();
		int totalStaff = dashboardService.getTotalStaff();
		int totalFamilies = dashboardService.getSnapshot().getTotalFamilies();
		int pendingRequests = dashboardService.getPendingVisitRequests();
		int approvedVisits = dashboardService.getApprovedVisits();

		// 4. Set data to request scope
		request.setAttribute("totalPrisoners", totalPrisoners);
		request.setAttribute("activePrisoners", activePrisoners);
		request.setAttribute("totalStaff", totalStaff);
		request.setAttribute("totalFamilies", totalFamilies);
		request.setAttribute("pendingRequests", pendingRequests);
		request.setAttribute("approvedVisits", approvedVisits);

		request.setAttribute("recentPrisoners", dashboardService.getRecentPrisoners(5));
		request.setAttribute("visitRequests", dashboardService.getPendingVisitRequests(5));
		request.setAttribute("activities", dashboardService.getRecentActivities(6));

		// 5. Forward to JSP
		request.getRequestDispatcher("/WEB-INF/pages/admin-dashboard.jsp").forward(request, response);
	}
}