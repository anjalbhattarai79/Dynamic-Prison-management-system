package com.anjal.controller;

import java.io.IOException;

import com.anjal.service.AuthService;
import com.anjal.service.AuthService.BasicResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles password reset using email + token.
 */
@WebServlet("/reset-password")
public class ResetPasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        BasicResult result = authService.resetPassword(email, token, newPassword, confirmPassword);
        if (result.isSuccess()) {
            request.setAttribute("message", result.getMessage());
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("email", email);
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
        }
    }
}
