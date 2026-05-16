<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.User" %>
<%@ page import="com.anjal.service.DashboardService.*" %>

<%
String adminName = (String) request.getAttribute("adminName");
if (adminName == null || adminName.trim().isEmpty()) {
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser != null && loggedInUser.getFullName() != null && !loggedInUser.getFullName().trim().isEmpty()) {
        adminName = loggedInUser.getFullName();
    } else {
        adminName = "Admin";
    }
}
String contextPath = request.getContextPath();

// Get data from request attributes
Integer totalPrisoners = (Integer) request.getAttribute("totalPrisoners");
Integer activePrisoners = (Integer) request.getAttribute("activePrisoners");
Integer totalFamilies = (Integer) request.getAttribute("totalFamilies");
Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
Integer approvedVisits = (Integer) request.getAttribute("approvedVisits");

List<PrisonerSummary> recentPrisoners = (List<PrisonerSummary>) request.getAttribute("recentPrisoners");
List<VisitRequestSummary> visitRequests = (List<VisitRequestSummary>) request.getAttribute("visitRequests");

if (totalPrisoners == null) totalPrisoners = 0;
if (activePrisoners == null) activePrisoners = 0;
if (totalFamilies == null) totalFamilies = 0;
if (pendingRequests == null) pendingRequests = 0;
if (approvedVisits == null) approvedVisits = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
</head>
<body>

<div class="layout">
    <!-- Sidebar -->
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />

    <div class="main-wrapper">
        <!-- Top Bar -->
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div>
                <div class="topbar-title">Welcome back, <%= adminName.split(" ")[0] %></div>
                <div class="topbar-sub" id="currentDate"></div>
            </div>
            <div class="topbar-right">
                <div class="date-badge" id="currentTime"></div>
                <div class="icon-btn" title="Search">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                </div>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Admin Dashboard</h1>
                    <p>System overview and quick management access</p>
                </div>
                <a href="<%= contextPath %>/add-prisoner" class="btn btn-primary">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add Prisoner
                </a>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </div>
                    <div class="stat-value"><%= totalPrisoners %></div>
                    <div class="stat-label">Total Prisoners</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <div class="stat-value"><%= activePrisoners %></div>
                    <div class="stat-label">Active Prisoners</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon warn">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    </div>
                    <div class="stat-value"><%= pendingRequests %></div>
                    <div class="stat-label">Pending Visits</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon navy">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                    </div>
                    <div class="stat-value"><%= totalFamilies %></div>
                    <div class="stat-label">Family Accounts</div>
                </div>
            </div>

            <div class="content-grid">
                <div class="list">
                    <!-- Recent Prisoners -->
                    <div class="card">
                        <div class="card-header">
                            <h3>Recent Prisoners</h3>
                            <a href="<%= contextPath %>/prisoner-list">View All</a>
                        </div>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Block</th>
                                    <th>Security</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (recentPrisoners == null || recentPrisoners.isEmpty()) { %>
                                    <tr><td colspan="5" style="text-align:center; padding:20px;">No prisoners found</td></tr>
                                <% } else {
                                    for (PrisonerSummary p : recentPrisoners) { %>
                                    <tr>
                                        <td><code><%= p.getPrisonerId() %></code></td>
                                        <td><%= p.getFullName() %></td>
                                        <td><%= p.getBlockNumber() %></td>
                                        <td><span class="sec-<%= p.getSecurityLevel().toLowerCase() %>"><%= p.getSecurityLevel() %></span></td>
                                        <td><span class="badge badge-<%= p.getStatus().toLowerCase() %>"><%= p.getStatus() %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pending Visits -->
                    <div class="card">
                        <div class="card-header">
                            <h3>Pending Visits</h3>
                            <a href="<%= contextPath %>/admin/visit-management">Manage</a>
                        </div>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Visitor</th>
                                    <th>Prisoner</th>
                                    <th>Date</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (visitRequests == null || visitRequests.isEmpty()) { %>
                                    <tr><td colspan="4" style="text-align:center; padding:20px;">No pending visits</td></tr>
                                <% } else {
                                    for (VisitRequestSummary v : visitRequests) { %>
                                    <tr>
                                        <td><%= v.getVisitorName() %></td>
                                        <td><%= v.getPrisonerName() %></td>
                                        <td><%= v.getPreferredDate() %></td>
                                        <td><a href="<%= contextPath %>/admin/visit-management">Review</a></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Right Side Actions -->
                <div class="card">
                    <div class="card-header"><h3>Quick Actions</h3></div>
                    <div class="quick-actions">
                        <a href="<%= contextPath %>/add-prisoner" class="quick-btn">
                            <div class="quick-btn-icon blue"><svg viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></div>
                            Add Prisoner
                        </a>
                        <a href="javascript:alert('Coming soon!')" class="quick-btn">
                            <div class="quick-btn-icon green"><svg viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div>
                            Add Staff
                        </a>
                        <a href="<%= contextPath %>/admin/visit-management" class="quick-btn">
                            <div class="quick-btn-icon warn"><svg viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                            Visits
                        </a>
                        <a href="<%= contextPath %>/trash" class="quick-btn">
                            <div class="quick-btn-icon navy"><svg viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/></svg></div>
                            Trash
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function updateDateTime() {
        const now = new Date();
        document.getElementById('currentDate').textContent = now.toLocaleDateString('en-US', {weekday:'long',year:'numeric',month:'long',day:'numeric'});
        document.getElementById('currentTime').textContent = now.toLocaleTimeString('en-US', {hour:'2-digit',minute:'2-digit'});
    }
    updateDateTime();
    setInterval(updateDateTime, 30000);
</script>
</body>
</html>
