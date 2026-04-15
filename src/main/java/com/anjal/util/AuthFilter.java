package com.anjal.util;

import java.io.IOException;

import com.anjal.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Authentication and simple authorization filter.
 * - Ensures a user is logged in for /admin/*, /staff/*, /family/*
 * - Checks role name to avoid cross-role access.
 */
@WebFilter(urlPatterns = {"/admin/*", "/staff/*", "/family/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        User user = (User) httpRequest.getSession().getAttribute("loggedInUser");

        if (user == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        String contextPath = httpRequest.getContextPath();
        String path = httpRequest.getRequestURI().substring(contextPath.length());
        String roleName = user.getRole() != null ? user.getRole().getName() : null;

        if (path.startsWith("/admin/") && (roleName == null || !"ADMIN".equalsIgnoreCase(roleName))) {
            httpResponse.sendRedirect(contextPath + "/unauthorized");
            return;
        }
        if (path.startsWith("/staff/") && (roleName == null || !"STAFF".equalsIgnoreCase(roleName))) {
            httpResponse.sendRedirect(contextPath + "/unauthorized");
            return;
        }
        if (path.startsWith("/family/") && (roleName == null || !"FAMILY".equalsIgnoreCase(roleName))) {
            httpResponse.sendRedirect(contextPath + "/unauthorized");
            return;
        }

        chain.doFilter(request, response);
    }
}
