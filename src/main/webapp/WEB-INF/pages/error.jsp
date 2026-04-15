<%@ page isErrorPage="true" language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Something went wrong - Prison Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
</head>
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
                <h2 class="card-title">Unexpected error</h2>
                <p class="card-subtitle">An unexpected problem occurred while processing your request.</p>
            </div>
            <p style="font-size:0.9rem; color:#9ca3af; margin-top:8px;">Please try again, or contact the administrator if the problem persists.</p>
            <% if (exception != null) { %>
                <p style="margin-top:12px; font-size:0.8rem; color:#6b7280;">Technical details (for debugging during development):</p>
                <pre style="max-height:140px; overflow:auto; font-size:0.75rem; background:rgba(15,23,42,0.8); padding:8px 10px; border-radius:8px; color:#e5e7eb;"><%= exception.getClass().getSimpleName() %>: <%= exception.getMessage() %></pre>
            <% } %>
        </div>
    </main>
</div>
</body>
</html>
