package com.anjal.controller;

import java.io.IOException;

import com.anjal.service.AuthService;
import com.anjal.service.AuthService.BasicResult;
import com.anjal.service.AuthService.PasswordResetInitResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller for handling password reset functionality.
 */
@WebServlet({ "/forgot-password", "/reset-password" })
public class ForgotPasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("DEBUG: ForgotPasswordController.doGet called");
        request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/forgot-password".equals(servletPath)) {
            handleInitiateReset(request, response);
        } else if ("/reset-password".equals(servletPath)) {
            handlePasswordReset(request, response);
        }
    }

    private void handleInitiateReset(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");

        PasswordResetInitResult result = authService.initiatePasswordReset(email);

        if (result.isSuccess()) {
            request.setAttribute("successMsg", "Reset token generated successfully: " + result.getToken());
        } else {
            request.setAttribute("errorMsg", result.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
    }

    private void handlePasswordReset(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        BasicResult result = authService.resetPassword(email, token, newPassword, confirmPassword);

        if (result.isSuccess()) {
            request.setAttribute("successMsg", "Your password has been updated. You can now login.");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMsg", result.getMessage());
            request.setAttribute("showResetForm", true);
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
        }
    }
}
