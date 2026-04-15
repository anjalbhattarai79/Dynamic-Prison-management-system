<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Forgot Password - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
</head>
<body>
<div class="auth-container">
    <h2>Forgot Password</h2>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert error"><%= request.getAttribute("error") %></div>
    <% } %>

    <% if (request.getAttribute("message") != null) { %>
        <div class="alert success"><%= request.getAttribute("message") %></div>
    <% } %>

    <% if (request.getAttribute("token") != null) { %>
        <div class="alert info">
            Demo reset token (for academic testing):<br>
            <strong><%= request.getAttribute("token") %></strong>
        </div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/forgot-password" class="auth-form">
        <label for="email">Registered Email</label>
        <input type="email" id="email" name="email" required>

        <button type="submit">Generate Reset Token</button>
    </form>

    <div class="auth-links">
        <a href="${pageContext.request.contextPath}/reset-password">Already have a token? Reset password</a>
        <a href="${pageContext.request.contextPath}/login">Back to login</a>
    </div>
</div>
</body>
</html>
