<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.FamilyMember" %>
<%
    List<FamilyMember> families = (List<FamilyMember>) request.getAttribute("families");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Family Management | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />
    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round" style="width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:2"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div class="topbar-title">Family Management</div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Family Members</h1>
                    <p>Manage registered family portal accounts</p>
                </div>
            </div>

            <div class="table-card">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Family Member</th>
                            <th>Relation</th>
                            <th>Prisoner</th>
                            <th>Visits (Total/Pending)</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (families == null || families.isEmpty()) { %>
                            <tr><td colspan="5" class="empty-state">No family records found.</td></tr>
                        <% } else { 
                            for (FamilyMember f : families) { %>
                            <tr>
                                <td class="text-bold"><%= f.getUser().getFullName() %></td>
                                <td><%= f.getRelation() %></td>
                                <td><%= f.getPrisoner().getFullName() %></td>
                                <td>
                                    <span class="badge badge-info"><%= f.getTotalVisits() %> Total</span>
                                    <% if(f.getPendingVisits() > 0) { %>
                                        <span class="badge badge-warn"><%= f.getPendingVisits() %> Pending</span>
                                    <% } %>
                                </td>
                                <td><a href="<%= contextPath %>/family-list?id=<%= f.getId() %>" class="btn btn-secondary btn-sm">View Details</a></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>