<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.anjal.model.User" %>
<%
    String contextPath = request.getContextPath();
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    String roleName = (loggedInUser != null && loggedInUser.getRole() != null) ? loggedInUser.getRole().getName() : "User";
    String fullName = (loggedInUser != null) ? loggedInUser.getFullName() : "Administrator";
    
    // Determine active page
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
%>

<!-- Sidebar Overlay for Mobile -->
<div class="sidebar-overlay" id="overlay" onclick="closeSidebar()"></div>

<!-- Sidebar Component -->
<nav class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="sidebar-logo-inner">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <div class="logo-text">
                <h2>PMS Nepal</h2>
                <p><%= roleName %> Portal</p>
            </div>
        </div>
    </div>

    <div class="sidebar-nav">
        <p class="nav-section-label">Overview</p>
        <a href="<%= contextPath %>/admin-dashboard" class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Dashboard
        </a>

        <p class="nav-section-label">Management</p>
        <a href="<%= contextPath %>/prisoner-list" class="nav-item <%= "prisoners".equals(activePage) ? "active" : "" %>">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            Prisoners
        </a>
        <a href="<%= contextPath %>/family-list" class="nav-item <%= "families".equals(activePage) ? "active" : "" %>">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            Family Members
        </a>
        <a href="<%= contextPath %>/staff-management" class="nav-item <%= "staff".equals(activePage) ? "active" : "" %>">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Staff
        </a>

        <p class="nav-section-label">Operations</p>
        <a href="<%= contextPath %>/admin/visit-management" class="nav-item <%= "visits".equals(activePage) ? "active" : "" %>">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            Visit Requests
        </a>

        <p class="nav-section-label">System</p>
        <a href="<%= contextPath %>/trash" class="nav-item <%= "trash".equals(activePage) ? "active" : "" %>">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
            Trash / Restore
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="user-info">
            <div class="user-avatar"><%= fullName.substring(0,1).toUpperCase() %></div>
            <div class="user-details">
                <p><%= fullName %></p>
                <span><%= roleName %></span>
            </div>
            <a href="<%= contextPath %>/logout" class="logout-btn" title="Logout">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            </a>
        </div>
    </div>
</nav>

<script>
    function openSidebar() {
        document.getElementById('sidebar').classList.add('open');
        document.getElementById('overlay').classList.add('show');
    }
    function closeSidebar() {
        document.getElementById('sidebar').classList.remove('open');
        document.getElementById('overlay').classList.remove('show');
    }
</script>
