<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Family Registration - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
________________________________________________________________________________</head>
<body>
<div class="page-shell">
    <header class="top-nav">
        <div class="top-nav-title">Secure Prison Management</div>
        <div class="top-nav-actions">
            <a href="${pageContext.request.contextPath}/home">Home</a>
            <a href="${pageContext.request.contextPath}/login">Login</a>
        </div>
    </header>
    <main class="page-main">
        <div class="auth-container">
            <div class="card-header">
                <h2 class="card-title">Create family account</h2>
                <p class="card-subtitle">Access prisoner information and request visits</p>
            </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert error"><%= request.getAttribute("error") %></div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/register" class="auth-form">
        <label for="fullName">Full Name</label>
        <input type="text" id="fullName" name="fullName" value="${fullName}" required>

        <label for="email">Email</label>
        <input type="email" id="email" name="email" value="${email}" required>

        <label for="password">Password</label>
        <input type="password" id="password" name="password" required>

        <label for="confirmPassword">Confirm Password</label>
        <input type="password" id="confirmPassword" name="confirmPassword" required>

        <button type="submit">Register</button>
    </form>

    <div class="auth-links">
        <a href="${pageContext.request.contextPath}/login">Back to login</a>
    </div>
</div>
</body>
</html>
