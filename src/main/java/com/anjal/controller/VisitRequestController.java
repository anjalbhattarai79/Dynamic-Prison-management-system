package com.anjal.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import com.anjal.dao.FamilyDAO;
import com.anjal.dao.PrisonerDAO;
import com.anjal.model.FamilyMember;
import com.anjal.model.Prisoner;
import com.anjal.model.User;
import com.anjal.model.VisitRequest;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/family/request-visit")
public class VisitRequestController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final FamilyDAO familyDAO = new FamilyDAO();
    private final PrisonerDAO prisonerDAO = new PrisonerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User loggedInUser = SessionUtil.getLoggedInUser(request.getSession(false));
        if (loggedInUser == null || !"FAMILY".equalsIgnoreCase(loggedInUser.getRole().getName())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            List<Prisoner> linkedPrisoners = familyDAO.getLinkedPrisoners(loggedInUser.getId());
            if (linkedPrisoners != null && !linkedPrisoners.isEmpty()) {
                request.setAttribute("selectedPrisoner", linkedPrisoners.get(0));
            }
            request.setAttribute("linkedPrisoners", linkedPrisoners);
            request.getRequestDispatcher("/WEB-INF/pages/visit-request.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User loggedInUser = SessionUtil.getLoggedInUser(request.getSession(false));
        if (loggedInUser == null || !"FAMILY".equalsIgnoreCase(loggedInUser.getRole().getName())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String prisonerIdStr = request.getParameter("prisonerId");
        String preferredDateStr = request.getParameter("preferredDate");
        String relation = request.getParameter("relation");
        String message = request.getParameter("message");

        try {
            int prisonerId = Integer.parseInt(prisonerIdStr);
            LocalDate preferredDate = LocalDate.parse(preferredDateStr);
            
            FamilyMember fm = familyDAO.getFamilyMemberByUserId(loggedInUser.getId());
            Prisoner p = new Prisoner();
            p.setId(prisonerId);

            VisitRequest vr = new VisitRequest();
            vr.setPrisoner(p);
            vr.setFamilyMember(fm);
            vr.setRequestDate(LocalDate.now());
            vr.setPreferredVisitDate(preferredDate);
            vr.setRelation(relation);
            vr.setMessage(message);

            familyDAO.saveVisitRequest(vr);

            response.sendRedirect(request.getContextPath() + "/family-dashboard?success=visit_requested");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to submit request: " + e.getMessage());
            doGet(request, response);
        }
    }
}
