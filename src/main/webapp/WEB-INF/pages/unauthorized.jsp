<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Unauthorized - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
________________________________________________________________________________</head>
<body>
<div class="page-shell">
    <header class="top-nav">
        <div class="top-nav-title">Secure Prison Management</div>
        <div class="top-nav-actions">
            <a href="${pageContext.request.contextPath}/home">Home</a>
        </div>
    </header>
    <main class="page-main">
        <div class="auth-container">
            <div class="card-header">
                <h2 class="card-title">Access denied</h2>
                <p class="card-subtitle">You do not have permission to access this resource.</p>
            </div>
            <div class="home-actions">
                <a class="pill-link" href="${pageContext.request.contextPath}/home">Go to Home</a>
            </div>
        </div>
    </main>
</div>
</body>
</html>
