<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Management | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
</head>
<body>

<div class="layout">
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />

    <div class="main-wrapper">
        <div class="topbar">
            <div class="topbar-title">Staff Management</div>
        </div>

        <div class="page-content">
            <div class="card" style="padding: 40px; text-align: center;">
                <div style="font-size: 48px; margin-bottom: 20px;">🏗️</div>
                <h2 style="margin-bottom: 10px;">Staff Management Coming Soon</h2>
                <p style="color: var(--text-sub);">This feature is currently under development. Please check back later.</p>
            </div>
        </div>
    </div>
</div>
</body>
</html>
