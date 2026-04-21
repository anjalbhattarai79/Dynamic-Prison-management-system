package com.anjal.controller;

import java.io.IOException;
import java.util.List;

import com.anjal.model.User;
import com.anjal.service.FamilyDashboardService;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Family Dashboard Controller
 * Responsibilities:
 * - Load specific prisoner data linked to the family from DB
 * - Load visit request history from DB
 * - Load notifications and summary stats from DB
 */
@WebServlet("/family-dashboard")
public class FamilyDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final FamilyDashboardService dashboardService = new FamilyDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = SessionUtil.getLoggedInUser(request.getSession(false));
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = user.getId();

        // 1. Load Profile & Relationship Data
        request.setAttribute("familyName", user.getFullName());
        request.setAttribute("initials", getInitials(user.getFullName()));

        // 2. Load Summary Stats from Service using DB
        request.setAttribute("upcomingVisits", dashboardService.getUpcomingVisitsCount(userId));
        request.setAttribute("pendingRequests", dashboardService.getPendingRequestsCount(userId));
        request.setAttribute("approvedVisits", dashboardService.getApprovedVisitsCount(userId));
        request.setAttribute("unreadNotifications", dashboardService.getUnreadNotificationsCount(userId));
        request.setAttribute("nextVisitDate", dashboardService.getNextVisitDate(userId));

        // 3. Load Authorized Prisoner Data
        List<FamilyDashboardService.Prisoner> prisoners = dashboardService.getLinkedPrisoners(userId);
        if (prisoners != null && !prisoners.isEmpty()) {
            request.setAttribute("prisoner", prisoners.get(0));
        }

        // 4. Load Lists for Tables
        request.setAttribute("recentVisits", dashboardService.getRecentVisitRequests(userId));
        request.setAttribute("recentNotifications", dashboardService.getRecentNotifications(userId));

        // 5. Forward to JSP
        request.getRequestDispatcher("/WEB-INF/pages/family-dashboard.jsp").forward(request, response);
    }
    
    private String getInitials(String name) {
        if (name == null || name.isEmpty()) return "??";
        String[] parts = name.split(" ");
        StringBuilder sb = new StringBuilder();
        for (String part : parts) {
            if (!part.isEmpty()) sb.append(part.charAt(0));
        }
        return sb.toString().toUpperCase();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
