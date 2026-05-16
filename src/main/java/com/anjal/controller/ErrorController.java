package com.anjal.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ErrorController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Tomcat sets these attributes when forwarding to an error page
        Object statusAttr = request.getAttribute("jakarta.servlet.error.status_code");
        String statusCode = (statusAttr != null) ? statusAttr.toString() : request.getParameter("code");
        
        if (statusCode == null) {
            statusCode = "500";
        }
        
        String message;
        String title;
        
        switch (statusCode) {
            case "404":
                title = "Page Not Found";
                message = "The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.";
                break;
            case "403":
                title = "Access Denied";
                message = "You don't have permission to access this resource.";
                break;
            default:
                title = "Something Went Wrong";
                message = "An unexpected error occurred. Our team has been notified and we're working to fix it.";
                break;
        }
        
        request.setAttribute("errorTitle", title);
        request.setAttribute("errorMessage", message);
        request.setAttribute("errorCode", statusCode);
        
        request.getRequestDispatcher("/WEB-INF/pages/error.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
