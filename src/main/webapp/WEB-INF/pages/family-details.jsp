<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.FamilyMember" %>
<%@ page import="com.anjal.model.VisitRequest" %>
<%
    FamilyMember family = (FamilyMember) request.getAttribute("family");
    List<VisitRequest> visits = (List<VisitRequest>) request.getAttribute("visits");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Family Details | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
</head>
<body>

<div class="layout">
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />

    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div class="topbar-title">Family Details</div>
        </div>

        <div class="page-content">
            <div class="card">
                <h2 class="section-title">Family Member Information</h2>
                <div class="info-grid">
                    <div class="info-item"><label>Full Name</label><span><%= family.getUser().getFullName() %></span></div>
                    <div class="info-item"><label>Email</label><span><%= family.getUser().getEmail() %></span></div>
                    <div class="info-item"><label>Phone</label><span><%= family.getPhone() != null ? family.getPhone() : "N/A" %></span></div>
                    <div class="info-item"><label>Address</label><span><%= family.getAddress() != null ? family.getAddress() : "N/A" %></span></div>
                    <div class="info-item"><label>Linked Prisoner</label><span><%= family.getPrisoner().getFullName() %> (<%= family.getPrisoner().getPrisonerId() %>)</span></div>
                    <div class="info-item"><label>Relation</label><span><%= family.getRelation() %></span></div>
                </div>
            </div>

            <div class="card">
                <h2 class="section-title">Visit History</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Relation Provided</th>
                            <th>Message</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(visits == null || visits.isEmpty()) { %>
                            <tr><td colspan="4" class="empty-state">No visit history found.</td></tr>
                        <% } else { 
                            for(VisitRequest v : visits) { %>
                            <tr>
                                <td><%= v.getPreferredVisitDate() %></td>
                                <td><%= v.getRelation() %></td>
                                <td><%= v.getMessage() != null ? v.getMessage() : "-" %></td>
                                <td><span class="badge badge-<%= v.getStatus().toLowerCase() %>"><%= v.getStatus() %></span></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
            
            <a href="<%= contextPath %>/family-list" class="btn btn-secondary btn-sm" style="margin-top: 20px;">← Back to Family List</a>
        </div>
    </div>
</div>

</body>
</html>
