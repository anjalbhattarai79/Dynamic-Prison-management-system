package com.anjal.controller;

import java.io.IOException;
import com.anjal.model.User;
import com.anjal.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/family/inquiries")
public class InquiryController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User loggedInUser = SessionUtil.getLoggedInUser(request.getSession(false));
        if (loggedInUser == null || !"FAMILY".equalsIgnoreCase(loggedInUser.getRole().getName())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/pages/inquiry.jsp").forward(request, response);
    }
}
