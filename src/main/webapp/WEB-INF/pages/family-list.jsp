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
    <link rel="stylesheet" href="<%= contextPath %>/css/theme.css">
    <style>
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .card { background: white; border-radius: 12px; border: 1px solid #d0d9ee; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th { background: #f4f6fb; padding: 12px 16px; text-align: left; font-size: 11px; text-transform: uppercase; color: #5a7099; border-bottom: 1px solid #d0d9ee; }
        .data-table td { padding: 14px 16px; border-bottom: 1px solid #e8edf7; font-size: 13px; }
        .btn-view { color: #3a6fd8; text-decoration: none; font-weight: 500; }
        .btn-view:hover { text-decoration: underline; }
    </style>
</head>
<body class="bg-cloud">
    <div style="padding: 30px; max-width: 1200px; margin: 0 auto;">
        <div class="page-header">
            <div>
                <h1 style="font-size: 24px; color: #1a2744;">Family Management</h1>
                <p style="color: #5a7099; font-size: 14px;">View and manage registered family portal accounts</p>
            </div>
            <a href="<%= contextPath %>/admin-dashboard" style="color: #5a7099; text-decoration: none; font-size: 14px;">← Back to Dashboard</a>
        </div>

        <div class="card">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Family Name</th>
                        <th>Prisoner ID</th>
                        <th>Prisoner Name</th>
                        <th>Relation</th>
                        <th>Email / Username</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (families == null || families.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center; padding: 40px; color: #8e9ec1;">No family records found.</td></tr>
                    <% } else { 
                        for (FamilyMember f : families) { %>
                        <tr>
                            <td style="font-weight: 500;"><%= f.getUser().getFullName() %></td>
                            <td><code><%= f.getPrisoner().getPrisonerId() %></code></td>
                            <td><%= f.getPrisoner().getFullName() %></td>
                            <td><%= f.getRelation() %></td>
                            <td style="color: #5a7099;"><%= f.getUser().getEmail() %></td>
                            <td>
                                <a href="<%= contextPath %>/family-list?id=<%= f.getId() %>" class="btn-view">View Details & History</a>
                            </td>
                        </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
