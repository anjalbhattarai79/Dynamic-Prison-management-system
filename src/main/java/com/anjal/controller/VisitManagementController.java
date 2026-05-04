package com.anjal.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import com.anjal.dao.VisitDAO;
import com.anjal.model.VisitRequest;
import com.anjal.model.VisitSchedule;
import com.anjal.model.User;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet({ "/admin/visit-management", "/admin/visit-respond" })
public class VisitManagementController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User loggedInUser = SessionUtil.getLoggedInUser(request.getSession(false));
        if (loggedInUser == null || (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole().getName()) && !"STAFF".equalsIgnoreCase(loggedInUser.getRole().getName()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            List<VisitRequest> pendingRequests = visitDAO.findAllPending();
            request.setAttribute("pendingRequests", pendingRequests);
            request.getRequestDispatcher("/WEB-INF/pages/visit-management.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User loggedInUser = SessionUtil.getLoggedInUser(request.getSession(false));
        if (loggedInUser == null || (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole().getName()) && !"STAFF".equalsIgnoreCase(loggedInUser.getRole().getName()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String requestIdStr = request.getParameter("requestId");
        String status = request.getParameter("status"); // APPROVED or REJECTED
        String scheduledDateStr = request.getParameter("scheduledDate");
        String scheduledTimeStr = request.getParameter("scheduledTime");
        String room = request.getParameter("room");
        String notes = request.getParameter("notes");

        try {
            int requestId = Integer.parseInt(requestIdStr);
            VisitSchedule schedule = null;

            if ("APPROVED".equalsIgnoreCase(status)) {
                schedule = new VisitSchedule();
                schedule.setScheduledDate(LocalDate.parse(scheduledDateStr));
                schedule.setScheduledTime(LocalTime.parse(scheduledTimeStr));
                schedule.setRoom(room);
                schedule.setNotes(notes);
            }

            visitDAO.updateStatusAndSchedule(requestId, status, schedule);

            response.sendRedirect(request.getContextPath() + "/admin/visit-management?success=responded");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/visit-management?error=failed");
        }
    }
}
