<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("userId") == null || 
        (!("ADMIN".equals(session.getAttribute("role"))) && !("STAFF".equals(session.getAttribute("role"))))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String role = (String) session.getAttribute("role");
    String userName = (String) session.getAttribute("fullName");
    if (userName == null) userName = "User";
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Management | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744;--navy-mid:#243358;--blue-acc:#3a6fd8;--blue-light:#4f85ec;
            --steel:#5a7099;--mist:#e8edf7;--cloud:#f4f6fb;--white:#ffffff;
            --border:#d0d9ee;--border-light:#e8edf7;--text-main:#1a2744;--text-sub:#5a7099;--text-light:#8e9ec1;
            --sidebar-w:260px;--header-h:64px;
            --shadow-sm:0 2px 8px rgba(26,39,68,.07);--transition:.2s ease
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}
        
        /* ── Sidebar ── */
        .sidebar{width:var(--sidebar-w);min-height:100vh;background:var(--navy);display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;z-index:100}
        .sidebar-logo{padding:20px 24px 16px;border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo-inner{display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:rgba(255,255,255,.12);border-radius:10px;display:flex;align-items:center;justify-content:center}
        .logo-icon svg{width:18px;height:18px;fill:none;stroke:#fff;stroke-width:1.8}
        .logo-text h2{font-family:'Playfair Display',Georgia,serif;font-size:14px;font-weight:600;color:#fff}
        .logo-text p{font-size:10px;color:rgba(255,255,255,.45);letter-spacing:.08em;text-transform:uppercase}
        .sidebar-nav{flex:1;padding:16px 0;overflow-y:auto}
        .nav-section-label{padding:8px 24px 4px;font-size:10px;color:rgba(255,255,255,.30);letter-spacing:.12em;text-transform:uppercase;font-weight:500}
        .nav-item{display:flex;align-items:center;gap:12px;padding:10px 24px;color:rgba(255,255,255,.65);text-decoration:none;font-size:13px;border-left:3px solid transparent;transition:all var(--transition)}
        .nav-item:hover{color:#fff;background:rgba(255,255,255,.06);border-left-color:rgba(255,255,255,.2)}
        .nav-item.active{color:#fff;background:rgba(58,111,216,.25);border-left-color:var(--blue-light);font-weight:500}
        .nav-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.7;flex-shrink:0}
        .sidebar-footer{padding:16px 24px;border-top:1px solid rgba(255,255,255,.08)}
        .user-info{display:flex;align-items:center;gap:10px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,var(--blue-acc),var(--blue-light));border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:#fff}
        .user-details p{font-size:12.5px;color:#fff;font-weight:500}
        .user-details span{font-size:10.5px;color:rgba(255,255,255,.45)}
        .logout-btn{margin-left:auto;background:none;border:none;cursor:pointer;color:rgba(255,255,255,.4);padding:4px;display:flex}
        .logout-btn:hover{color:rgba(255,255,255,.8)}
        .logout-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:2}
        
        .main-wrapper{margin-left:var(--sidebar-w);flex:1;display:flex;flex-direction:column}
        .topbar{height:var(--header-h);background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px;gap:16px;position:sticky;top:0;z-index:50;box-shadow:var(--shadow-sm)}
        .topbar-title{font-size:16px;font-weight:600}
        .page-content{padding:28px;flex:1;display:flex;align-items:center;justify-content:center;text-align:center}
        
        .placeholder-card{background:white;padding:60px 40px;border-radius:20px;box-shadow:var(--shadow-sm);max-width:500px;border:1px solid var(--border-light)}
        .placeholder-icon{width:80px;height:80px;background:var(--cloud);border-radius:20px;display:flex;align-items:center;justify-content:center;margin:0 auto 24px;color:var(--blue-acc)}
        .placeholder-icon svg{width:40px;height:40px;stroke:currentColor;fill:none;stroke-width:1.5}
        .placeholder-card h1{font-family:'Playfair Display',serif;font-size:28px;color:var(--navy);margin-bottom:12px}
        .placeholder-card p{color:var(--text-sub);line-height:1.6;font-size:15px;margin-bottom:24px}
        .status-badge{display:inline-block;padding:6px 14px;background:var(--blue-pale);color:var(--blue-acc);border-radius:30px;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:1px;background:#eef4fd}
    </style>
</head>
<body>

<div class="layout">
    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <div class="logo-text"><h2>PMS Nepal</h2><p>Admin Portal</p></div>
            </div>
        </div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/admin-dashboard" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>Dashboard</a>
            <p class="nav-section-label" style="margin-top:8px">Management</p>
            <a href="<%= contextPath %>/prisoner-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>Prisoners</a>
            <a href="<%= contextPath %>/staff-management.jsp" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>Staff</a>
            <a href="<%= contextPath %>/family-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>Family Members</a>

            <p class="nav-section-label" style="margin-top:8px">Operations</p>
            <a href="<%= contextPath %>/admin/visit-management" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>Visit Requests</a>
            <a href="<%= contextPath %>/trash" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>Trash / Restore</a>
        </div>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= userName.substring(0,1).toUpperCase() %></div>
                <div class="user-details"><p><%= userName %></p><span><%= role %></span></div>
                <a href="<%= contextPath %>/logout" class="logout-btn"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></a>
            </div>
        </div>
    </nav>

    <div class="main-wrapper">
        <div class="topbar">
            <div class="topbar-title">Staff Management</div>
        </div>

        <div class="page-content">
            <div class="placeholder-card">
                <div class="placeholder-icon">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                </div>
                <span class="status-badge">Under Construction</span>
                <h1>Coming Soon</h1>
                <p>We are working hard to bring you the Staff Management module. This feature will allow you to manage prison staff, assign roles, and track performance.</p>
                <a href="<%= contextPath %>/admin-dashboard" class="nav-item" style="display:inline-flex; border:1.5px solid var(--border); border-radius:10px; padding:10px 20px; color:var(--navy); font-weight:500; background:white">
                    Back to Dashboard
                </a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
