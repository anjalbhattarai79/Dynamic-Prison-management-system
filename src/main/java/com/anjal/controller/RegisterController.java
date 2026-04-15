package com.anjal.controller;

import java.io.IOException;

import com.anjal.service.AuthService;
import com.anjal.service.AuthService.RegistrationResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles self-registration for family members.
 */
@WebServlet("/register")
public class RegisterController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        RegistrationResult result = authService.registerFamily(fullName, email, password, confirmPassword);
        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        request.setAttribute("message", "Registration successful. You can now log in.");
        request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
    }
}
