<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.User" %>
<%@ page import="com.anjal.service.DashboardService.*" %>
<%-- Security check: only admin can access --%>
<%-- <%
    if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String adminName = (String) session.getAttribute("fullName");
    if (adminName == null) adminName = "Administrator";
%> --%>

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
Integer totalStaff = (Integer) request.getAttribute("totalStaff");
Integer totalFamilies = (Integer) request.getAttribute("totalFamilies");
Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
Integer approvedVisits = (Integer) request.getAttribute("approvedVisits");

List<PrisonerSummary> recentPrisoners = (List<PrisonerSummary>) request.getAttribute("recentPrisoners");
List<VisitRequestSummary> visitRequests = (List<VisitRequestSummary>) request.getAttribute("visitRequests");
List<ActivitySummary> activities = (List<ActivitySummary>) request.getAttribute("activities");

if (totalPrisoners == null) totalPrisoners = 0;
if (activePrisoners == null) activePrisoners = 0;
if (totalStaff == null) totalStaff = 0;
if (totalFamilies == null) totalFamilies = 0;
if (pendingRequests == null) pendingRequests = 0;
if (approvedVisits == null) approvedVisits = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744;--navy-mid:#243358;--navy-light:#2e4170;
            --blue-acc:#3a6fd8;--blue-light:#4f85ec;--blue-pale:#e8eef9;
            --steel:#5a7099;--mist:#e8edf7;--cloud:#f4f6fb;--white:#ffffff;
            --border:#d0d9ee;--border-light:#e8edf7;
            --text-main:#1a2744;--text-sub:#5a7099;--text-light:#8e9ec1;
            --success:#1e7d5a;--success-bg:#edf7f3;--success-border:#a8dece;
            --warn:#b07d10;--warn-bg:#fdf8ea;--warn-border:#f0d478;
            --error:#c94040;--error-bg:#fef2f2;--error-border:#f5c0c0;
            --info:#2a5fa5;--info-bg:#eef4fd;
            --sidebar-w:260px;--header-h:64px;
            --shadow-sm:0 2px 8px rgba(26,39,68,.07);--shadow-md:0 4px 16px rgba(26,39,68,.10);
            --radius:12px;--radius-sm:8px;--transition:.2s ease
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        /* ── Layout ── */
        .layout{display:flex;min-height:100vh}
        /* ── Sidebar ── */
        .sidebar{
            width:var(--sidebar-w);min-height:100vh;background:var(--navy);
            display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;
            z-index:100;transition:transform var(--transition)
        }
        .sidebar-logo{padding:20px 24px 16px;border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo-inner{display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:rgba(255,255,255,.12);border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .logo-icon svg{width:18px;height:18px;fill:none;stroke:#fff;stroke-width:1.8}
        .logo-text h2{font-family:'Playfair Display',Georgia,serif;font-size:14px;font-weight:600;color:#fff;line-height:1.2}
        .logo-text p{font-size:10px;color:rgba(255,255,255,.45);letter-spacing:.08em;text-transform:uppercase}
        .sidebar-nav{flex:1;padding:16px 0;overflow-y:auto}
        .nav-section-label{padding:8px 24px 4px;font-size:10px;color:rgba(255,255,255,.30);letter-spacing:.12em;text-transform:uppercase;font-weight:500}
        .nav-item{display:flex;align-items:center;gap:12px;padding:10px 24px;color:rgba(255,255,255,.65);text-decoration:none;font-size:13px;font-weight:400;border-left:3px solid transparent;transition:all var(--transition);cursor:pointer}
        .nav-item:hover{color:#fff;background:rgba(255,255,255,.06);border-left-color:rgba(255,255,255,.2)}
        .nav-item.active{color:#fff;background:rgba(58,111,216,.25);border-left-color:var(--blue-light);font-weight:500}
        .nav-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.7;flex-shrink:0}
        .nav-badge{margin-left:auto;background:rgba(217,79,79,.85);color:#fff;font-size:10px;font-weight:600;padding:2px 7px;border-radius:20px}
        .nav-badge.green{background:rgba(30,125,90,.8)}
        .sidebar-footer{padding:16px 24px;border-top:1px solid rgba(255,255,255,.08)}
        .user-info{display:flex;align-items:center;gap:10px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,var(--blue-acc),var(--blue-light));border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:#fff;flex-shrink:0}
        .user-details p{font-size:12.5px;color:#fff;font-weight:500;line-height:1.2}
        .user-details span{font-size:10.5px;color:rgba(255,255,255,.45)}
        .logout-btn{margin-left:auto;background:none;border:none;cursor:pointer;color:rgba(255,255,255,.4);padding:4px;transition:color var(--transition);display:flex}
        .logout-btn:hover{color:rgba(255,255,255,.8)}
        .logout-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:2}
        /* ── Main ── */
        .main-wrapper{margin-left:var(--sidebar-w);flex:1;display:flex;flex-direction:column;min-height:100vh}
        /* ── Top bar ── */
        .topbar{height:var(--header-h);background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px;gap:16px;position:sticky;top:0;z-index:50;box-shadow:var(--shadow-sm)}
        .topbar-title{font-size:16px;font-weight:600;color:var(--text-main)}
        .topbar-sub{font-size:12px;color:var(--text-light);margin-top:1px}
        .topbar-right{margin-left:auto;display:flex;align-items:center;gap:12px}
        .icon-btn{width:36px;height:36px;background:var(--cloud);border:1px solid var(--border);border-radius:var(--radius-sm);display:flex;align-items:center;justify-content:center;cursor:pointer;position:relative;transition:background var(--transition)}
        .icon-btn:hover{background:var(--mist)}
        .icon-btn svg{width:15px;height:15px;fill:none;stroke:var(--steel);stroke-width:1.8}
        .notif-dot{position:absolute;top:7px;right:7px;width:7px;height:7px;background:var(--error);border-radius:50%;border:1.5px solid var(--white)}
        .date-badge{font-size:12px;color:var(--text-sub);background:var(--cloud);border:1px solid var(--border);padding:6px 12px;border-radius:20px}
        /* ── Page content ── */
        .page-content{padding:28px;flex:1}
        .page-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:28px;gap:16px;flex-wrap:wrap}
        .page-header h1{font-size:22px;font-weight:600;color:var(--text-main)}
        .page-header p{font-size:13px;color:var(--text-sub);margin-top:3px}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border-radius:var(--radius-sm);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;text-decoration:none;transition:all var(--transition);border:none}
        .btn-primary{background:linear-gradient(135deg,var(--navy),var(--blue-acc));color:#fff;box-shadow:0 3px 10px rgba(58,111,216,.30)}
        .btn-primary:hover{opacity:.9;transform:translateY(-1px)}
        .btn-secondary{background:var(--white);color:var(--text-main);border:1px solid var(--border)}
        .btn-secondary:hover{background:var(--cloud)}
        .btn svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:2}
        /* ── Stats grid ── */
        .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:28px}
        .stat-card{background:var(--white);border-radius:var(--radius);padding:20px;border:1px solid var(--border-light);box-shadow:var(--shadow-sm);transition:box-shadow var(--transition),transform var(--transition);cursor:default}
        .stat-card:hover{box-shadow:var(--shadow-md);transform:translateY(-2px)}
        .stat-top{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:14px}
        .stat-icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center}
        .stat-icon svg{width:18px;height:18px;fill:none;stroke-width:1.8}
        .stat-icon.blue{background:var(--info-bg);stroke:var(--info)}
        .stat-icon.blue svg{stroke:var(--info)}
        .stat-icon.green{background:var(--success-bg)}
        .stat-icon.green svg{stroke:var(--success)}
        .stat-icon.warn{background:var(--warn-bg)}
        .stat-icon.warn svg{stroke:var(--warn)}
        .stat-icon.error{background:var(--error-bg)}
        .stat-icon.error svg{stroke:var(--error)}
        .stat-icon.purple{background:#f0eeff}
        .stat-icon.purple svg{stroke:#6c47d5}
        .stat-icon.navy{background:var(--blue-pale)}
        .stat-icon.navy svg{stroke:var(--navy)}
        .stat-change{font-size:11px;font-weight:500;padding:3px 7px;border-radius:20px}
        .stat-change.up{background:var(--success-bg);color:var(--success)}
        .stat-change.down{background:var(--error-bg);color:var(--error)}
        .stat-change.neutral{background:var(--cloud);color:var(--text-sub)}
        .stat-value{font-size:28px;font-weight:600;color:var(--text-main);line-height:1;margin-bottom:4px}
        .stat-label{font-size:12.5px;color:var(--text-sub)}
        /* ── Two-column layout ── */
        .content-grid{display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start}
        @media(max-width:1100px){.content-grid{grid-template-columns:1fr}}
        /* ── Cards ── */
        .card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);box-shadow:var(--shadow-sm);overflow:hidden}
        .card-header{display:flex;align-items:center;justify-content:space-between;padding:18px 20px 14px;border-bottom:1px solid var(--border-light)}
        .card-header h3{font-size:14px;font-weight:600;color:var(--text-main)}
        .card-header a{font-size:12px;color:var(--blue-acc);text-decoration:none;font-weight:500}
        .card-header a:hover{text-decoration:underline}
        /* ── Table ── */
        .data-table{width:100%;border-collapse:collapse}
        .data-table th{padding:10px 16px;font-size:11px;font-weight:600;color:var(--text-light);text-transform:uppercase;letter-spacing:.08em;text-align:left;background:var(--cloud);border-bottom:1px solid var(--border-light)}
        .data-table td{padding:12px 16px;font-size:13px;color:var(--text-main);border-bottom:1px solid var(--border-light)}
        .data-table tr:last-child td{border-bottom:none}
        .data-table tr:hover td{background:var(--cloud)}
        .data-table a{color:var(--blue-acc);text-decoration:none;font-weight:500}
        .data-table a:hover{text-decoration:underline}
        /* ── Badges ── */
        .badge{display:inline-flex;align-items:center;gap:5px;font-size:11px;font-weight:500;padding:3px 9px;border-radius:20px;white-space:nowrap}
        .badge::before{content:'';width:5px;height:5px;border-radius:50%;flex-shrink:0}
        .badge-active{background:var(--success-bg);color:var(--success);border:1px solid var(--success-border)}
        .badge-active::before{background:var(--success)}
        .badge-pending{background:var(--warn-bg);color:var(--warn);border:1px solid var(--warn-border)}
        .badge-pending::before{background:var(--warn)}
        .badge-approved{background:var(--info-bg);color:var(--info);border:1px solid #b8d0f0}
        .badge-approved::before{background:var(--info)}
        .badge-rejected{background:var(--error-bg);color:var(--error);border:1px solid var(--error-border)}
        .badge-rejected::before{background:var(--error)}
        .badge-released{background:var(--cloud);color:var(--text-sub);border:1px solid var(--border)}
        .badge-released::before{background:var(--text-light)}
        .badge-transferred{background:#eef4fd;color:var(--info);border:1px solid #b8d0f0}
        .badge-transferred::before{background:var(--info)}
        /* ── Activity feed ── */
        .activity-list{display:flex;flex-direction:column}
        .activity-item{display:flex;align-items:flex-start;gap:12px;padding:14px 20px;border-bottom:1px solid var(--border-light)}
        .activity-item:last-child{border-bottom:none}
        .activity-dot{width:8px;height:8px;border-radius:50%;margin-top:4px;flex-shrink:0}
        .activity-dot.add, .activity-dot.LOGIN_SUCCESS{background:#1e7d5a}
        .activity-dot.update, .activity-dot.VISIT_REQUEST_APPROVED{background:var(--blue-acc)}
        .activity-dot.delete{background:var(--error)}
        .activity-dot.visit, .activity-dot.INQUIRY_SUBMITTED{background:#b07d10}
        .activity-dot.login{background:#6c47d5}
        .activity-body p{font-size:13px;color:var(--text-main);line-height:1.4}
        .activity-body span{font-size:11.5px;color:var(--text-light)}
        /* ── Quick actions ── */
        .quick-actions{display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:16px}
        .quick-btn{display:flex;flex-direction:column;align-items:center;gap:8px;padding:14px 10px;background:var(--cloud);border:1px solid var(--border-light);border-radius:var(--radius-sm);text-decoration:none;color:var(--text-main);font-size:12px;font-weight:500;text-align:center;transition:all var(--transition)}
        .quick-btn:hover{background:var(--mist);border-color:var(--blue-acc);color:var(--blue-acc)}
        .quick-btn-icon{width:36px;height:36px;border-radius:9px;display:flex;align-items:center;justify-content:center}
        .quick-btn-icon svg{width:17px;height:17px;fill:none;stroke-width:1.8}
        .quick-btn-icon.blue{background:var(--info-bg)}
        .quick-btn-icon.blue svg{stroke:var(--info)}
        .quick-btn-icon.green{background:var(--success-bg)}
        .quick-btn-icon.green svg{stroke:var(--success)}
        .quick-btn-icon.warn{background:var(--warn-bg)}
        .quick-btn-icon.warn svg{stroke:var(--warn)}
        .quick-btn-icon.purple{background:#f0eeff}
        .quick-btn-icon.purple svg{stroke:#6c47d5}
        /* ── Security level indicator ── */
        .sec-high{color:#c94040;font-weight:500}
        .sec-medium{color:var(--warn);font-weight:500}
        .sec-low{color:var(--success);font-weight:500}
        /* ── Mobile sidebar toggle ── */
        .mobile-menu-btn{display:none;background:none;border:none;cursor:pointer;padding:4px}
        .mobile-menu-btn svg{width:20px;height:20px;stroke:var(--text-main);fill:none;stroke-width:2}
        @media(max-width:900px){
            .sidebar{transform:translateX(-100%)}
            .sidebar.open{transform:translateX(0)}
            .main-wrapper{margin-left:0}
            .mobile-menu-btn{display:flex}
            .stats-grid{grid-template-columns:repeat(2,1fr)}
        }
        @media(max-width:560px){.stats-grid{grid-template-columns:1fr}}
        /* ── Overlay for mobile ── */
        .sidebar-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:99}
        .sidebar-overlay.show{display:block}
    </style>
</head>
<body>

<div class="sidebar-overlay" id="overlay" onclick="closeSidebar()"></div>

<div class="layout">
    <!-- ══ SIDEBAR ══ -->
    <nav class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <div class="logo-text">
                    <h2>PMS Nepal</h2>
                    <p>Admin Portal</p>
                </div>
            </div>
        </div>

        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/admin-dashboard" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Dashboard
            </a>

            <p class="nav-section-label" style="margin-top:8px">Management</p>
            <a href="<%= contextPath %>/prisoner-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                Prisoners
            </a>
            <a href="staff-management.jsp" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                Staff
            </a>
            <a href="<%= contextPath %>/family-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                Family Members
            </a>

            <p class="nav-section-label" style="margin-top:8px">Operations</p>
            <a href="<%= contextPath %>/admin/visit-management" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Visit Requests
                <span class="nav-badge" id="pendingBadge"><%= pendingRequests %></span>
            </a>
            <a href="activity-tracking.jsp" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                Activity Tracking
            </a>
            <a href="notifications.jsp" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                Notifications
            </a>

            <p class="nav-section-label" style="margin-top:8px">System</p>
            <a href="<%= contextPath %>/trash" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                Trash / Restore
            </a>
            <a href="reports.jsp" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                Reports & Logs
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= adminName.substring(0,1).toUpperCase() %></div>
                <div class="user-details">
                    <p><%= adminName %></p>
                    <span>Administrator</span>
                </div>
                <a href="<%= contextPath %>/logout" class="logout-btn" title="Logout">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                </a>
            </div>
        </div>
    </nav>

    <!-- ══ MAIN CONTENT ══ -->
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
                <a href="notifications.jsp" class="icon-btn" title="Notifications">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                    <span class="notif-dot"></span>
                </a>
            </div>
        </div>

        <!-- Page Content -->
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Admin Dashboard</h1>
                    <p>System overview and quick management access</p>
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <a href="reports.jsp" class="btn btn-secondary">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                        Reports
                    </a>
                    <a href="<%= contextPath %>/add-prisoner" class="btn btn-primary">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Add Prisoner
                    </a>
                </div>
            </div>

            <!-- ── Stats Cards ── -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon blue">
                            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                        <span class="stat-change neutral">Total</span>
                    </div>
                    <div class="stat-value"><%= totalPrisoners %></div>
                    <div class="stat-label">Total Prisoners</div>
                </div>
                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon green">
                            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                        </div>
                        <span class="stat-change up">Active</span>
                    </div>
                    <div class="stat-value"><%= activePrisoners %></div>
                    <div class="stat-label">Active Prisoners</div>
                </div>
                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon warn">
                            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                        <span class="stat-change neutral">Pending</span>
                    </div>
                    <div class="stat-value"><%= pendingRequests %></div>
                    <div class="stat-label">Pending Visit Requests</div>
                </div>
                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon blue" style="background:#eef4fd">
                            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                        </div>
                        <span class="stat-change up">This month</span>
                    </div>
                    <div class="stat-value"><%= approvedVisits %></div>
                    <div class="stat-label">Approved Visits</div>
                </div>
                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon navy">
                            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                        </div>
                        <span class="stat-change neutral">Registered</span>
                    </div>
                    <div class="stat-value"><%= totalFamilies %></div>
                    <div class="stat-label">Family Accounts</div>
                </div>
            </div>

            <!-- ── Content Grid ── -->
            <div class="content-grid">
                <div style="display:flex;flex-direction:column;gap:20px">
                    <!-- Recent Prisoners -->
                    <div class="card">
                        <div class="card-header">
                            <h3>Recently Added Prisoners</h3>
                            <a href="<%= contextPath %>/prisoner-list">View all →</a>
                        </div>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Prisoner ID</th>
                                    <th>Full Name</th>
                                    <th>Crime Type</th>
                                    <th>Block</th>
                                    <th>Security</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (recentPrisoners == null || recentPrisoners.isEmpty()) {
                                %>
                                <tr><td colspan="6" style="text-align:center;padding:24px;color:var(--text-light)">No prisoners found</td></tr>
                                <%
                                    } else {
                                        for (PrisonerSummary p : recentPrisoners) {
                                %>
                                <tr>
                                    <td><a href="#"><%= p.getPrisonerId() %></a></td>
                                    <td><%= p.getFullName() %></td>
                                    <td><%= p.getCrimeType() %></td>
                                    <td>Block <%= p.getBlockNumber() %></td>
                                    <td><span class="sec-<%= p.getSecurityLevel().toLowerCase() %>"><%= p.getSecurityLevel() %></span></td>
                                    <td><span class="badge badge-<%= p.getStatus().toLowerCase() %>"><%= p.getStatus() %></span></td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Visit Requests -->
                    <div class="card">
                        <div class="card-header">
                            <h3>Pending Visit Requests</h3>
                            <a href="<%= contextPath %>/admin/visit-management">Manage all →</a>
                        </div>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Request ID</th>
                                    <th>Visitor</th>
                                    <th>Prisoner</th>
                                    <th>Preferred Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (visitRequests == null || visitRequests.isEmpty()) {
                                %>
                                <tr><td colspan="6" style="text-align:center;padding:24px;color:var(--text-light)">No pending requests</td></tr>
                                <%
                                    } else {
                                        for (VisitRequestSummary v : visitRequests) {
                                %>
                                <tr>
                                    <td>#<%= v.getRequestId() %></td>
                                    <td><%= v.getVisitorName() %></td>
                                    <td><%= v.getPrisonerName() %></td>
                                    <td><%= v.getPreferredDate() %></td>
                                    <td><span class="badge badge-pending">Pending</span></td>
                                    <td><a href="<%= contextPath %>/admin/visit-management">Review</a></td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Right panel -->
                <div style="display:flex;flex-direction:column;gap:20px">
                    <!-- Quick Actions -->
                    <div class="card">
                        <div class="card-header"><h3>Quick Actions</h3></div>
                        <div class="quick-actions">
                            <a href="<%= contextPath %>/add-prisoner" class="quick-btn">
                                <div class="quick-btn-icon blue"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></div>
                                Add Prisoner
                            </a>
                            <a href="staff-management.jsp?action=add" class="quick-btn">
                                <div class="quick-btn-icon green"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg></div>
                                Add Staff
                            </a>
                            <a href="<%= contextPath %>/admin/visit-management" class="quick-btn">
                                <div class="quick-btn-icon warn"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                                Review Visits
                            </a>
                            <a href="<%= contextPath %>/trash" class="quick-btn">
                                <div class="quick-btn-icon purple"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg></div>
                                Trash & Restore
                            </a>
                            <a href="reports.jsp" class="quick-btn">
                                <div class="quick-btn-icon blue"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg></div>
                                View Reports
                            </a>
                            <a href="<%= contextPath %>/prisoner-list?search=true" class="quick-btn">
                                <div class="quick-btn-icon green"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
                                Search Records
                            </a>
                        </div>
                    </div>

                    <!-- Recent Activity Feed -->
                    <div class="card">
                        <div class="card-header">
                            <h3>Recent Activity</h3>
                            <a href="reports.jsp">View logs →</a>
                        </div>
                        <div class="activity-list" id="activityFeed">
                            <%
                                if (activities == null || activities.isEmpty()) {
                            %>
                            <div style="padding:20px;text-align:center;color:var(--text-light);font-size:13px">No recent activity</div>
                            <%
                                } else {
                                    for (ActivitySummary a : activities) {
                            %>
                            <div class="activity-item">
                                <div class="activity-dot <%= a.getType() %>"></div>
                                <div class="activity-body">
                                    <p><%= a.getDescription() %></p>
                                    <span><%= a.getTimeAgo() %> · <%= a.getPerformedBy() %></span>
                                </div>
                            </div>
                            <%
                                    }
                                }
                            %>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /page-content -->
    </div><!-- /main-wrapper -->
</div><!-- /layout -->

<script>
    /* Date/Time display */
    function updateDateTime() {
        const now = new Date();
        document.getElementById('currentDate').textContent = now.toLocaleDateString('en-US', {weekday:'long',year:'numeric',month:'long',day:'numeric'});
        document.getElementById('currentTime').textContent = now.toLocaleTimeString('en-US', {hour:'2-digit',minute:'2-digit'});
    }
    updateDateTime();
    setInterval(updateDateTime, 30000);

    /* Mobile sidebar */
    function openSidebar() {
        document.getElementById('sidebar').classList.add('open');
        document.getElementById('overlay').classList.add('show');
    }
    function closeSidebar() {
        document.getElementById('sidebar').classList.remove('open');
        document.getElementById('overlay').classList.remove('show');
    }
</script>
</body>
</html>
