package com.anjal.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/family-request-visit")
public class RequestVisitController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setAttribute("prisonerName", "Ramesh Karki");
        request.setAttribute("prisonerId", "PR-0142");
        
        request.getRequestDispatcher("/WEB-INF/pages/request-visit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Form handling logic...
        response.sendRedirect(request.getContextPath() + "/family-dashboard?status=success");
    }
}