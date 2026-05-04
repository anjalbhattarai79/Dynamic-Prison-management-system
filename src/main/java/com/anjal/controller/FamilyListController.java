package com.anjal.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.anjal.dao.FamilyDAO;
import com.anjal.dao.VisitDAO;
import com.anjal.model.FamilyMember;
import com.anjal.model.User;
import com.anjal.model.VisitRequest;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/family-list")
public class FamilyListController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final FamilyDAO familyDAO = new FamilyDAO();
    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.getLoggedInUser(request.getSession(false));
        if (user == null || (!"ADMIN".equals(user.getRole().getName()) && !"STAFF".equals(user.getRole().getName()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String familyIdStr = request.getParameter("id");
        if (familyIdStr != null && !familyIdStr.isEmpty()) {
            showFamilyDetails(request, response, Integer.parseInt(familyIdStr));
        } else {
            showFamilyList(request, response);
        }
    }

    private void showFamilyList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<FamilyMember> families = familyDAO.findAllWithPrisonerDetails();
            request.setAttribute("families", families);
            request.getRequestDispatcher("/WEB-INF/pages/family-list.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void showFamilyDetails(HttpServletRequest request, HttpServletResponse response, int familyId)
            throws ServletException, IOException {
        try {
            FamilyMember family = familyDAO.findById(familyId);
            if (family == null) {
                response.sendRedirect(request.getContextPath() + "/family-list");
                return;
            }
            List<VisitRequest> visits = visitDAO.findByFamilyId(familyId);
            request.setAttribute("family", family);
            request.setAttribute("visits", visits);
            request.getRequestDispatcher("/WEB-INF/pages/family-details.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
