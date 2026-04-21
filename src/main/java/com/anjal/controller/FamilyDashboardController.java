package com.anjal.controller;

import java.io.IOException;
import java.util.List;

import com.anjal.service.FamilyDashboardService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Family Dashboard Controller
 * * Responsibilities:
 * - Load specific prisoner data linked to the family
 * - Load visit request history
 * - Load notifications and summary stats
 * - Forward to family dashboard JSP
 */
@WebServlet("/family-dashboard")
public class FamilyDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Use the specific Family service
    private final FamilyDashboardService dashboardService = new FamilyDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        // 1. Load Profile & Relationship Data (Sita Thapa context)
        request.setAttribute("familyName", "Sita Thapa");
        request.setAttribute("relationship", "Spouse");
        request.setAttribute("initials", "ST");

        // 2. Load Summary Stats from Service
        request.setAttribute("upcomingVisits", dashboardService.getUpcomingVisitsCount());
        request.setAttribute("pendingRequests", dashboardService.getPendingRequestsCount());
        request.setAttribute("approvedVisits", dashboardService.getApprovedVisitsCount());
        request.setAttribute("unreadNotifications", dashboardService.getUnreadNotificationsCount());
        request.setAttribute("nextVisitDate", dashboardService.getNextVisitDate());

        // 3. Load Authorized Prisoner Data
        // Since we removed the "linked list", we fetch the list and take the first one (Ramesh Karki)
        List<FamilyDashboardService.Prisoner> prisoners = dashboardService.getLinkedPrisoners();
        if (prisoners != null && !prisoners.isEmpty()) {
            request.setAttribute("prisoner", prisoners.get(0));
        }

        // 4. Load Lists for Tables
        request.setAttribute("recentVisits", dashboardService.getRecentVisitRequests());
        request.setAttribute("recentNotifications", dashboardService.getRecentNotifications());

        // 5. Forward to JSP
        request.getRequestDispatcher("/WEB-INF/pages/family-dashboard.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}