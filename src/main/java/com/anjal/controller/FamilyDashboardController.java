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

@WebServlet("/family-dashboard")
public class FamilyDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final FamilyDashboardService dashboardService = new FamilyDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User loggedInUser = SessionUtil.getLoggedInUser(request.getSession(false));
        if (loggedInUser == null || !"FAMILY".equalsIgnoreCase(loggedInUser.getRole().getName())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = loggedInUser.getId();
        System.out.println("DEBUG: Controller fetching data for userId: " + userId);

        // Populate dashboard data
        request.setAttribute("upcomingVisits", dashboardService.getUpcomingVisitsCount(userId));
        request.setAttribute("pendingRequests", dashboardService.getPendingRequestsCount(userId));
        request.setAttribute("approvedVisits", dashboardService.getApprovedVisitsCount(userId));
        request.setAttribute("unreadNotifications", dashboardService.getUnreadNotificationsCount(userId));
        request.setAttribute("nextVisitDate", dashboardService.getNextVisitDate(userId));
        
        List<FamilyDashboardService.VisitRequest> recentRequests = dashboardService.getRecentVisitRequests(userId);
        request.setAttribute("recentRequests", recentRequests);

        List<FamilyDashboardService.Prisoner> linkedPrisoners = dashboardService.getLinkedPrisoners(userId);
        request.setAttribute("linkedPrisoners", linkedPrisoners);

        List<FamilyDashboardService.Notification> notifications = dashboardService.getRecentNotifications(userId);
        request.setAttribute("notifications", notifications);

        request.getRequestDispatcher("/WEB-INF/pages/family-dashboard.jsp").forward(request, response);
    }
}
