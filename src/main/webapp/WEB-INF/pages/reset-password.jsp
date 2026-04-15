<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Password - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
________________________________________________________________________________</head>
<body>
<div class="page-shell">
    <header class="top-nav">
        <div class="top-nav-title">Secure Prison Management</div>
        <div class="top-nav-actions">
            <a href="${pageContext.request.contextPath}/login">Back to login</a>
        </div>
    </header>
    <main class="page-main">
        <div class="auth-container">
            <div class="card-header">
                <h2 class="card-title">Choose a new password</h2>
                <p class="card-subtitle">Use your email and reset token from the email</p>
            </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert error"><%= request.getAttribute("error") %></div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/reset-password" class="auth-form">
        <label for="email">Registered Email</label>
        <input type="email" id="email" name="email" value="${email}" required>

        <label for="token">Reset Token</label>
        <input type="text" id="token" name="token" value="${token}" required>

        <label for="newPassword">New Password</label>
        <input type="password" id="newPassword" name="newPassword" required>

        <label for="confirmPassword">Confirm New Password</label>
        <input type="password" id="confirmPassword" name="confirmPassword" required>

        <button type="submit">Reset Password</button>
    </form>

    <div class="auth-links">
        <a href="${pageContext.request.contextPath}/login">Back to login</a>
    </div>
</div>
</body>
</html>
