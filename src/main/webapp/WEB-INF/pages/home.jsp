<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.anjal.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
________________________________________________________________________________</head>
<body>
<div class="page-shell">
    <header class="top-nav">
        <div class="top-nav-title">Secure Prison Management</div>
    </header>
    <main class="page-main">
        <div class="home-container">
            <h1>Secure Prison Management &amp; Family Portal</h1>
    <%
        User user = (User) request.getAttribute("user");
        if (user != null) {
    %>
    <p>Welcome, <strong><%= user.getFullName() %></strong> (<%= user.getRole().getName() %>)</p>
    <div class="home-actions">
        <a class="pill-link" href="<%= request.getContextPath() %>/logout">Logout</a>
    </div>
    <%
        } else {
    %>
    <p>Welcome visitor. Please <a href="<%= request.getContextPath() %>/login">login</a> or <a href="<%= request.getContextPath() %>/register">register</a> as a family member.</p>
    <div class="home-actions">
        <a class="pill-link" href="<%= request.getContextPath() %>/login">Login</a>
        <a class="pill-link" href="<%= request.getContextPath() %>/register">Register</a>
    </div>
    <%
        }
    %>
        </div>
    </main>
</div>
</body>
</html>