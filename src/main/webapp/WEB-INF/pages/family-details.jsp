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
    <link rel="stylesheet" href="<%= contextPath %>/css/theme.css">
    <style>
        .details-grid { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; margin-bottom: 30px; }
        .card { background: white; border-radius: 12px; border: 1px solid #d0d9ee; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .info-label { color: #8e9ec1; font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px; display: block; }
        .info-value { color: #1a2744; font-size: 15px; font-weight: 500; margin-bottom: 16px; display: block; }
        .visit-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .visit-table th { text-align: left; font-size: 11px; color: #5a7099; padding: 12px; border-bottom: 2px solid #f4f6fb; }
        .visit-table td { padding: 12px; border-bottom: 1px solid #f4f6fb; font-size: 13px; }
        .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        .status-PENDING { background: #fdf8ea; color: #b07d10; }
        .status-APPROVED { background: #eef4fd; color: #3a6fd8; }
        .status-COMPLETED { background: #edf7f3; color: #1e7d5a; }
        .status-REJECTED { background: #fef2f2; color: #c94040; }
    </style>
</head>
<body class="bg-cloud">
    <div style="padding: 30px; max-width: 1200px; margin: 0 auto;">
        <div style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;">
            <h1 style="font-size: 24px; color: #1a2744;">Family Portal Account Details</h1>
            <a href="<%= contextPath %>/family-list" style="color: #5a7099; text-decoration: none; font-size: 14px;">← Back to List</a>
        </div>

        <div class="details-grid">
            <div class="card">
                <h3 style="margin-bottom: 20px; font-size: 16px;">Family Profile</h3>
                
                <span class="info-label">Full Name</span>
                <span class="info-value"><%= family.getUser().getFullName() %></span>
                
                <span class="info-label">Email / ID</span>
                <span class="info-value"><%= family.getUser().getEmail() %></span>
                
                <span class="info-label">Relationship</span>
                <span class="info-value"><%= family.getRelation() %></span>
                
                <span class="info-label">Linked Prisoner</span>
                <span class="info-value"><%= family.getPrisoner().getFullName() %> (<%= family.getPrisoner().getPrisonerId() %>)</span>
                
                <span class="info-label">Phone Number</span>
                <span class="info-value"><%= (family.getPhone() != null) ? family.getPhone() : "Not provided" %></span>
                
                <span class="info-label">Current Address</span>
                <span class="info-value"><%= (family.getAddress() != null) ? family.getAddress() : "Not provided" %></span>
            </div>

            <div class="card">
                <h3 style="margin-bottom: 20px; font-size: 16px;">Visit History</h3>
                <table class="visit-table">
                    <thead>
                        <tr>
                            <th>Request Date</th>
                            <th>Visit Date</th>
                            <th>Status</th>
                            <th>Message</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (visits == null || visits.isEmpty()) { %>
                            <tr><td colspan="4" style="text-align:center; padding: 40px; color: #8e9ec1;">No visit history found.</td></tr>
                        <% } else { 
                            for (VisitRequest v : visits) { %>
                            <tr>
                                <td><%= v.getRequestDate() %></td>
                                <td><%= v.getPreferredVisitDate() %></td>
                                <td><span class="status-badge status-<%= v.getStatus() %>"><%= v.getStatus() %></span></td>
                                <td style="color: #5a7099; font-size: 12px;"><%= (v.getMessage() != null) ? v.getMessage() : "-" %></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
