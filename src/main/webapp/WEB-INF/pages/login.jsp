<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
</head>
<body>
<div class="auth-container">
    <h2>Secure Login</h2>

    <c:if test="${not empty param.message && param.message eq 'loggedout'}">
        <div class="alert success">You have been logged out.</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert error">${error}</div>
    </c:if>

    <c:if test="${not empty message}">
        <div class="alert success">${message}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/login" class="auth-form">
        <label for="email">Email</label>
        <input type="email" id="email" name="email" value="${email}" required>

        <label for="password">Password</label>
        <input type="password" id="password" name="password" required>

        <button type="submit">Login</button>
    </form>

    <div class="auth-links">
        <a href="${pageContext.request.contextPath}/register">New family member? Register</a>
        <a href="${pageContext.request.contextPath}/forgot-password">Forgot password?</a>
    </div>
</div>

</body>
</html>
