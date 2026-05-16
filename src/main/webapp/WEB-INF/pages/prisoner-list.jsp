<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
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

<%
String adminName = (String) session.getAttribute("adminName");
if (adminName == null || adminName.trim().isEmpty()) {
    adminName = "Admin";
}
String prisonersJson = (String) request.getAttribute("prisonersJson");
if (prisonersJson == null || prisonersJson.trim().isEmpty()) {
    prisonersJson = "[]";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prisoner Management | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744;--navy-mid:#243358;--blue-acc:#3a6fd8;--blue-light:#4f85ec;
            --steel:#5a7099;--mist:#e8edf7;--cloud:#f4f6fb;--white:#ffffff;
            --border:#d0d9ee;--border-light:#e8edf7;--text-main:#1a2744;--text-sub:#5a7099;--text-light:#8e9ec1;
            --success:#1e7d5a;--success-bg:#edf7f3;--success-border:#a8dece;
            --warn:#b07d10;--warn-bg:#fdf8ea;--warn-border:#f0d478;
            --error:#c94040;--error-bg:#fef2f2;--error-border:#f5c0c0;
            --info:#2a5fa5;--info-bg:#eef4fd;
            --sidebar-w:260px;--header-h:64px;
            --shadow-sm:0 2px 8px rgba(26,39,68,.07);--shadow-md:0 4px 16px rgba(26,39,68,.10);
            --radius:12px;--radius-sm:8px;--transition:.2s ease
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}
        /* ── Sidebar (same as admin-dashboard) ── */
        .sidebar{width:var(--sidebar-w);min-height:100vh;background:var(--navy);display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;z-index:100;transition:transform var(--transition)}
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
        .nav-badge{margin-left:auto;background:rgba(217,79,79,.85);color:#fff;font-size:10px;font-weight:600;padding:2px 7px;border-radius:20px}
        .nav-badge.green{background:rgba(30,125,90,.8)}
        .sidebar-footer{padding:16px 24px;border-top:1px solid rgba(255,255,255,.08)}
        .user-info{display:flex;align-items:center;gap:10px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,var(--blue-acc),var(--blue-light));border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:#fff;flex-shrink:0}
        .user-details p{font-size:12.5px;color:#fff;font-weight:500}
        .user-details span{font-size:10.5px;color:rgba(255,255,255,.45)}
        .logout-btn{margin-left:auto;background:none;border:none;cursor:pointer;color:rgba(255,255,255,.4);padding:4px;display:flex}
        .logout-btn:hover{color:rgba(255,255,255,.8)}
        .logout-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:2}
        /* ── Main ── */
        .main-wrapper{margin-left:var(--sidebar-w);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{height:var(--header-h);background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px;gap:16px;position:sticky;top:0;z-index:50;box-shadow:var(--shadow-sm)}
        .topbar-title{font-size:16px;font-weight:600;color:var(--text-main)}
        .breadcrumb{display:flex;align-items:center;gap:6px;font-size:12px;color:var(--text-light)}
        .breadcrumb a{color:var(--blue-acc);text-decoration:none}
        .breadcrumb a:hover{text-decoration:underline}
        .breadcrumb span{font-size:11px}
        .topbar-right{margin-left:auto;display:flex;align-items:center;gap:12px}
        .page-content{padding:28px;flex:1}
        .page-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:24px;gap:16px;flex-wrap:wrap}
        .page-header h1{font-size:22px;font-weight:600;color:var(--text-main)}
        .page-header p{font-size:13px;color:var(--text-sub);margin-top:3px}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border-radius:var(--radius-sm);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;text-decoration:none;transition:all var(--transition);border:none;white-space:nowrap}
        .btn-primary{background:linear-gradient(135deg,var(--navy),var(--blue-acc));color:#fff;box-shadow:0 3px 10px rgba(58,111,216,.30)}
        .btn-primary:hover{opacity:.9;transform:translateY(-1px)}
        .btn-secondary{background:var(--white);color:var(--text-main);border:1px solid var(--border)}
        .btn-secondary:hover{background:var(--cloud)}
        .btn-danger{background:var(--white);color:var(--error);border:1px solid var(--error-border)}
        .btn-danger:hover{background:var(--error-bg)}
        .btn-sm{padding:6px 12px;font-size:12px}
        .btn svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:2;flex-shrink:0}
        /* ── Filters toolbar ── */
        .filters-bar{background:var(--white);border:1px solid var(--border-light);border-radius:var(--radius);padding:16px 20px;margin-bottom:20px;display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;box-shadow:var(--shadow-sm)}
        .filter-group{display:flex;flex-direction:column;gap:5px;min-width:140px}
        .filter-group label{font-size:11px;font-weight:500;color:var(--text-light);text-transform:uppercase;letter-spacing:.08em}
        .filter-group input,.filter-group select{padding:8px 12px;font-family:inherit;font-size:13px;color:var(--text-main);background:var(--cloud);border:1.5px solid var(--border);border-radius:var(--radius-sm);outline:none;transition:border-color var(--transition)}
        .filter-group input:focus,.filter-group select:focus{border-color:var(--blue-acc);background:var(--white)}
        .search-wrap{position:relative;flex:1;min-width:200px}
        .search-wrap svg{position:absolute;left:11px;top:50%;transform:translateY(-50%);width:15px;height:15px;stroke:var(--text-light);fill:none;stroke-width:1.8;pointer-events:none}
        .search-wrap input{padding-left:36px;width:100%}
        /* ── Table container ── */
        .table-card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);box-shadow:var(--shadow-sm);overflow:hidden}
        .table-toolbar{display:flex;align-items:center;justify-content:space-between;padding:14px 20px;border-bottom:1px solid var(--border-light);flex-wrap:wrap;gap:12px}
        .table-toolbar-left{display:flex;align-items:center;gap:10px}
        .results-count{font-size:12.5px;color:var(--text-sub)}
        .table-scroll{overflow-x:auto}
        .data-table{width:100%;border-collapse:collapse;min-width:800px}
        .data-table th{padding:11px 16px;font-size:11px;font-weight:600;color:var(--text-light);text-transform:uppercase;letter-spacing:.08em;text-align:left;background:var(--cloud);border-bottom:1px solid var(--border-light);white-space:nowrap;cursor:pointer;user-select:none}
        .data-table th:hover{color:var(--text-main)}
        .data-table th .sort-icon{display:inline-block;margin-left:4px;opacity:.4;font-size:10px}
        .data-table th.sort-asc .sort-icon::after{content:'↑';opacity:1}
        .data-table th.sort-desc .sort-icon::after{content:'↓';opacity:1}
        .data-table th .sort-icon::after{content:'↕'}
        .data-table td{padding:13px 16px;font-size:13px;color:var(--text-main);border-bottom:1px solid var(--border-light);vertical-align:middle}
        .data-table tr:last-child td{border-bottom:none}
        .data-table tr:hover td{background:#fafbfe}
        .data-table a{color:var(--blue-acc);text-decoration:none;font-weight:500}
        .data-table a:hover{text-decoration:underline}
        /* ── Badges ── */
        .badge{display:inline-flex;align-items:center;gap:4px;font-size:11px;font-weight:500;padding:3px 9px;border-radius:20px;white-space:nowrap}
        .badge::before{content:'';width:5px;height:5px;border-radius:50%}
        .badge-active{background:var(--success-bg);color:var(--success);border:1px solid var(--success-border)}
        .badge-active::before{background:var(--success)}
        .badge-released{background:var(--cloud);color:var(--text-sub);border:1px solid var(--border)}
        .badge-released::before{background:var(--text-light)}
        .badge-transferred{background:var(--info-bg);color:var(--info);border:1px solid #b8d0f0}
        .badge-transferred::before{background:var(--info)}
        .sec-high{color:#c94040;font-weight:500}
        .sec-medium{color:var(--warn);font-weight:500}
        .sec-low{color:var(--success);font-weight:500}
        /* ── Checkbox ── */
        .cb{accent-color:var(--blue-acc);width:15px;height:15px}
        /* ── Action btns ── */
        .action-btns{display:flex;gap:6px;align-items:center}
        .action-btn{width:30px;height:30px;border-radius:6px;border:1px solid var(--border);background:var(--white);display:flex;align-items:center;justify-content:center;cursor:pointer;text-decoration:none;transition:all var(--transition)}
        .action-btn svg{width:13px;height:13px;fill:none;stroke-width:2;flex-shrink:0}
        .action-btn.view{color:var(--blue-acc)}
        .action-btn.view:hover{background:var(--info-bg);border-color:var(--blue-acc)}
        .action-btn.view svg{stroke:var(--blue-acc)}
        .action-btn.edit{color:var(--warn)}
        .action-btn.edit:hover{background:var(--warn-bg);border-color:var(--warn-border)}
        .action-btn.edit svg{stroke:var(--warn)}
        .action-btn.delete{color:var(--error)}
        .action-btn.delete:hover{background:var(--error-bg);border-color:var(--error-border)}
        .action-btn.delete svg{stroke:var(--error)}
        /* ── Pagination ── */
        .pagination{display:flex;align-items:center;justify-content:space-between;padding:14px 20px;border-top:1px solid var(--border-light);flex-wrap:wrap;gap:10px}
        .pagination-info{font-size:12.5px;color:var(--text-sub)}
        .pagination-btns{display:flex;gap:4px}
        .page-btn{min-width:32px;height:32px;padding:0 6px;border:1px solid var(--border);background:var(--white);border-radius:6px;font-family:inherit;font-size:13px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all var(--transition);color:var(--text-main)}
        .page-btn:hover{background:var(--cloud)}
        .page-btn.active{background:var(--navy);color:#fff;border-color:var(--navy)}
        .page-btn:disabled{opacity:.4;cursor:not-allowed}
        /* ── Empty state ── */
        .empty-state{text-align:center;padding:60px 20px}
        .empty-state svg{width:48px;height:48px;stroke:var(--text-light);fill:none;stroke-width:1.3;margin-bottom:12px}
        .empty-state h3{font-size:15px;font-weight:500;color:var(--text-sub);margin-bottom:6px}
        .empty-state p{font-size:13px;color:var(--text-light)}
        /* ── Delete confirm modal ── */
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(26,39,68,.5);z-index:200;align-items:center;justify-content:center;padding:20px}
        .modal-overlay.show{display:flex}
        .modal{background:var(--white);border-radius:var(--radius);padding:28px;max-width:400px;width:100%;box-shadow:0 20px 60px rgba(26,39,68,.25)}
        .modal h3{font-size:16px;font-weight:600;color:var(--text-main);margin-bottom:8px}
        .modal p{font-size:13.5px;color:var(--text-sub);line-height:1.6;margin-bottom:20px}
        .modal-actions{display:flex;gap:10px;justify-content:flex-end}
        .prisoner-modal{max-width:760px;width:min(760px,100%)}
        .modal-header{display:flex;align-items:flex-start;justify-content:space-between;gap:16px;margin-bottom:18px}
        .modal-header h3{margin-bottom:4px}
        .modal-close{background:none;border:none;cursor:pointer;color:var(--text-light);padding:4px}
        .modal-close svg{width:18px;height:18px;stroke:currentColor;fill:none;stroke-width:2}
        .details-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px 18px;margin-bottom:18px}
        .detail-item{padding:12px 14px;background:var(--cloud);border:1px solid var(--border-light);border-radius:10px}
        .detail-label{display:block;font-size:10.5px;font-weight:600;color:var(--text-light);text-transform:uppercase;letter-spacing:.08em;margin-bottom:4px}
        .detail-value{font-size:13.5px;color:var(--text-main);font-weight:500;word-break:break-word}
        .edit-form{display:none}
        .edit-form.show{display:block}
        .details-view.show{display:block}
        .details-view{display:none}
        .modal-form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}
        .modal-field{display:flex;flex-direction:column;gap:6px}
        .modal-field label{font-size:12px;font-weight:500;color:var(--text-sub)}
        .modal-field input,.modal-field select{padding:10px 12px;border:1.5px solid var(--border);border-radius:8px;background:var(--cloud);font-family:inherit;font-size:13.5px;color:var(--text-main)}
        .modal-field input:focus,.modal-field select:focus{border-color:var(--blue-acc);background:var(--white);outline:none;box-shadow:0 0 0 3px rgba(58,111,216,.10)}
        .modal-field .span-2{grid-column:1 / -1}
        .prisoner-photo{width:46px;height:46px;border-radius:12px;object-fit:cover;border:1px solid var(--border);background:linear-gradient(135deg,#f7f9fd,#e8edf7)}
        .prisoner-photo-lg{width:150px;height:150px;border-radius:24px;object-fit:cover;border:1px solid var(--border);background:linear-gradient(135deg,#f7f9fd,#e8edf7)}
        .photo-shell{display:flex;justify-content:center;align-items:center;padding:16px;background:linear-gradient(135deg,#f7f9fd,#eef4fd);border:1px solid var(--border-light);border-radius:20px;margin-bottom:18px}
        /* ── Mobile ── */
        .mobile-menu-btn{display:none;background:none;border:none;cursor:pointer;padding:4px}
        .mobile-menu-btn svg{width:20px;height:20px;stroke:var(--text-main);fill:none;stroke-width:2}
        .sidebar-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:99}
        .sidebar-overlay.show{display:block}
        @media(max-width:900px){
            .sidebar{transform:translateX(-100%)}
            .sidebar.open{transform:translateX(0)}
            .main-wrapper{margin-left:0}
            .mobile-menu-btn{display:flex}
            .filters-bar{flex-direction:column}
            .filter-group{min-width:100%}
        }
    </style>
</head>
<body>
<div class="sidebar-overlay" id="overlay" onclick="closeSidebar()"></div>

<div class="layout">
    <!-- Sidebar -->
    <nav class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <div class="logo-text"><h2>PMS Nepal</h2><p><%= "ADMIN".equals(role) ? "Admin Portal" : "Staff Portal" %></p></div>
            </div>
        </div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/admin-dashboard" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Dashboard
            </a>

            <p class="nav-section-label" style="margin-top:8px">Management</p>
            <a href="<%= contextPath %>/prisoner-list" class="nav-item active">
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
                <%
                    Integer pendingCount = (Integer) session.getAttribute("pendingVisitRequestsCount");
                    if (pendingCount != null && pendingCount > 0) {
                %>
                <span class="nav-badge"><%= pendingCount %></span>
                <% } %>
            </a>
            <a href="<%= contextPath %>/trash" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                Trash / Restore
            </a>
        </div>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= adminName.substring(0,1).toUpperCase() %></div>
                <div class="user-details"><p><%= adminName %></p><span>Administrator</span></div>
                <a href="<%= contextPath %>/logout" class="logout-btn" title="Logout"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></a>
            </div>
        </div>
    </nav>

    <!-- Main -->
    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div>
                <div class="topbar-title">Prisoner Management</div>
                <div class="breadcrumb">
                    <a href="<%= contextPath %>/admin-dashboard">Dashboard</a>
                    <span>›</span><span>Prisoners</span>
                </div>
            </div>
            <div class="topbar-right">
            <a href="<%= contextPath %>/add-prisoner" class="btn btn-primary btn-sm">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add Prisoner
                </a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Prisoners</h1>
                    <p>Manage all prisoner records — search, filter, and update</p>
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <button class="btn btn-secondary btn-sm" onclick="exportCSV()">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        Export
                    </button>
                    <a href="<%= contextPath %>/add-prisoner" class="btn btn-primary btn-sm">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Add Prisoner
                    </a>
                </div>
            </div>

            <!-- Filters -->
            <div class="filters-bar">
                <div class="filter-group search-wrap" style="flex:2;min-width:220px">
                    <label>Search</label>
                    <div class="search-wrap">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" id="searchInput" placeholder="Name, ID, or crime type…" oninput="applyFilters()">
                    </div>
                </div>
                <div class="filter-group">
                    <label>Status</label>
                    <select id="filterStatus" onchange="applyFilters()">
                        <option value="">All Statuses</option>
                        <option value="Active">Active</option>
                        <option value="Released">Released</option>
                        <option value="Transferred">Transferred</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Security Level</label>
                    <select id="filterSecurity" onchange="applyFilters()">
                        <option value="">All Levels</option>
                        <option value="High">High</option>
                        <option value="Medium">Medium</option>
                        <option value="Low">Low</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Block</label>
                    <select id="filterBlock" onchange="applyFilters()">
                        <option value="">All Blocks</option>
                        <option value="A">Block A</option>
                        <option value="B">Block B</option>
                        <option value="C">Block C</option>
                        <option value="D">Block D</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Crime Type</label>
                    <select id="filterCrime" onchange="applyFilters()">
                        <option value="">All Types</option>
                        <option value="Murder">Murder</option>
                        <option value="Robbery">Robbery</option>
                        <option value="Fraud">Fraud</option>
                        <option value="Drug Trafficking">Drug Trafficking</option>
                        <option value="Assault">Assault</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <button class="btn btn-secondary btn-sm" onclick="clearFilters()" style="align-self:flex-end">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    Clear
                </button>
            </div>

            <!-- Table -->
            <div class="table-card">
                <div class="table-toolbar">
                    <div class="table-toolbar-left">
                        <span class="results-count" id="resultsCount">Loading…</span>
                        <button id="bulkDeleteBtn" class="btn btn-danger btn-sm" style="display:none" onclick="bulkDelete()">
                            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                            Delete Selected
                        </button>
                    </div>
                    <div style="display:flex;align-items:center;gap:10px">
                        <label style="font-size:12px;color:var(--text-sub)">Per page:</label>
                        <select id="perPage" onchange="applyFilters()" style="padding:5px 8px;border:1px solid var(--border);border-radius:6px;font-size:12px;background:var(--cloud)">
                            <option value="10">10</option>
                            <option value="25" selected>25</option>
                            <option value="50">50</option>
                        </select>
                    </div>
                </div>

                <div class="table-scroll">
                    <table class="data-table" id="prisonerTable">
                        <thead>
                            <tr>
                                <th style="width:40px"><input type="checkbox" class="cb" id="selectAll" onchange="toggleSelectAll(this)"></th>
                                <th style="width:72px">Photo</th>
                                <th onclick="sortTable('prisonerId')" data-col="prisonerId">ID <span class="sort-icon"></span></th>
                                <th onclick="sortTable('fullName')" data-col="fullName">Full Name <span class="sort-icon"></span></th>
                                <th onclick="sortTable('crimeType')" data-col="crimeType">Crime Type <span class="sort-icon"></span></th>
                                <th onclick="sortTable('sentenceYears')" data-col="sentenceYears">Sentence <span class="sort-icon"></span></th>
                                <th onclick="sortTable('blockNumber')" data-col="blockNumber">Block <span class="sort-icon"></span></th>
                                <th onclick="sortTable('securityLevel')" data-col="securityLevel">Security <span class="sort-icon"></span></th>
                                <th onclick="sortTable('admissionDate')" data-col="admissionDate">Admitted <span class="sort-icon"></span></th>
                                <th onclick="sortTable('status')" data-col="status">Status <span class="sort-icon"></span></th>
                                <th style="width:100px">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="prisonerTbody">
                            <tr><td colspan="11" style="text-align:center;padding:40px"><div style="display:inline-block;width:28px;height:28px;border:3px solid var(--border);border-top-color:var(--blue-acc);border-radius:50%;animation:spin .7s linear infinite"></div></td></tr>
                        </tbody>
                    </table>
                </div>

                <div class="pagination" id="paginationBar">
                    <span class="pagination-info" id="paginationInfo"></span>
                    <div class="pagination-btns" id="paginationBtns"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirm Modal -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <h3>Move to Trash?</h3>
        <p>This prisoner record will be moved to the trash. You can restore it later from the Trash section. This action does not permanently delete the record.</p>
        <div class="modal-actions">
            <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
            <button class="btn btn-danger" id="confirmDeleteBtn" onclick="confirmDelete()">Move to Trash</button>
        </div>
    </div>
</div>

<!-- Prisoner Details Modal -->
<div class="modal-overlay" id="prisonerModal">
    <div class="modal prisoner-modal">
        <div class="modal-header">
            <div>
                <h3 id="modalTitle">Prisoner Details</h3>
                <p id="modalSubtitle" style="margin-bottom:0">View, edit, or remove a prisoner record.</p>
            </div>
            <button class="modal-close" onclick="closePrisonerModal()" aria-label="Close">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>

        <div id="detailsView" class="details-view show">
                <div class="details-grid">
                <div class="detail-item" style="grid-column:1 / -1">
                    <span class="detail-label">Photo</span>
                    <div class="photo-shell">
                        <img id="viewPhoto" class="prisoner-photo-lg" alt="Prisoner photo">
                    </div>
                </div>
                <div class="detail-item"><span class="detail-label">Prisoner ID</span><span class="detail-value" id="viewPrisonerId"></span></div>
                <div class="detail-item"><span class="detail-label">Full Name</span><span class="detail-value" id="viewFullName"></span></div>
                <div class="detail-item"><span class="detail-label">Date of Birth</span><span class="detail-value" id="viewDateOfBirth"></span></div>
                <div class="detail-item"><span class="detail-label">Gender</span><span class="detail-value" id="viewGender"></span></div>
                <div class="detail-item"><span class="detail-label">Crime Type</span><span class="detail-value" id="viewCrimeType"></span></div>
                <div class="detail-item"><span class="detail-label">Sentence Years</span><span class="detail-value" id="viewSentenceYears"></span></div>
                <div class="detail-item"><span class="detail-label">Admission Date</span><span class="detail-value" id="viewAdmissionDate"></span></div>
                <div class="detail-item"><span class="detail-label">Release Date</span><span class="detail-value" id="viewReleaseDate"></span></div>
                <div class="detail-item"><span class="detail-label">Block Number</span><span class="detail-value" id="viewBlockNumber"></span></div>
                <div class="detail-item"><span class="detail-label">Security Level</span><span class="detail-value" id="viewSecurityLevel"></span></div>
                <div class="detail-item"><span class="detail-label">Status</span><span class="detail-value" id="viewStatus"></span></div>
                <div class="detail-item"><span class="detail-label">Emergency Contact</span><span class="detail-value" id="viewEmergencyContact"></span></div>
            </div>
            <div class="modal-actions">
                <button class="btn btn-secondary" onclick="openEditMode()">Edit</button>
                <button class="btn btn-danger" onclick="deleteFromModal()">Delete</button>
            </div>
        </div>

        <form id="editForm" class="edit-form" onsubmit="saveEdit(event)">
            <input type="hidden" id="editPrisonerId" name="prisonerId">
            <div class="modal-form-grid">
                <div class="modal-field span-2">
                    <label>Full Name</label>
                    <input type="text" id="editFullName" name="fullName" required>
                </div>
                <div class="modal-field">
                    <label>Date of Birth</label>
                    <input type="date" id="editDateOfBirth" name="dateOfBirth" required>
                </div>
                <div class="modal-field">
                    <label>Gender</label>
                    <select id="editGender" name="gender" required>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div class="modal-field">
                    <label>Crime Type</label>
                    <input type="text" id="editCrimeType" name="crimeType" required>
                </div>
                <div class="modal-field">
                    <label>Sentence Years</label>
                    <input type="number" id="editSentenceYears" name="sentenceYears" min="1" required>
                </div>
                <div class="modal-field">
                    <label>Admission Date</label>
                    <input type="date" id="editAdmissionDate" name="admissionDate" required>
                </div>
                <div class="modal-field">
                    <label>Release Date</label>
                    <input type="date" id="editReleaseDate" name="releaseDate">
                </div>
                <div class="modal-field">
                    <label>Block Number</label>
                    <input type="text" id="editBlockNumber" name="blockNumber" required>
                </div>
                <div class="modal-field">
                    <label>Security Level</label>
                    <select id="editSecurityLevel" name="securityLevel" required>
                        <option value="Low">Low</option>
                        <option value="Medium">Medium</option>
                        <option value="High">High</option>
                    </select>
                </div>
                <div class="modal-field">
                    <label>Status</label>
                    <select id="editStatus" name="status" required>
                        <option value="Active">Active</option>
                        <option value="Released">Released</option>
                        <option value="Transferred">Transferred</option>
                    </select>
                </div>
                <div class="modal-field span-2">
                    <label>Emergency Contact</label>
                    <input type="text" id="editEmergencyContact" name="emergencyContact">
                </div>
            </div>
            <div class="modal-actions" style="margin-top:18px">
                <button type="button" class="btn btn-secondary" onclick="cancelEditMode()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<style>@keyframes spin{to{transform:rotate(360deg)}}</style>

<script>
    let allPrisoners = <%= prisonersJson %>;
    let filteredPrisoners = [];
    let currentPage = 1;
    let sortCol = 'prisonerId';
    let sortDir = 'asc';
    let deleteTargetId = null;
    let selectedPrisoner = null;

    function applyFilters() {
        const search = document.getElementById('searchInput').value.toLowerCase();
        const status = document.getElementById('filterStatus').value;
        const security = document.getElementById('filterSecurity').value;
        const block = document.getElementById('filterBlock').value;
        const crime = document.getElementById('filterCrime').value;

        filteredPrisoners = allPrisoners.filter(p => {
            const matchSearch = !search || p.fullName.toLowerCase().includes(search) ||
                p.prisonerId.toLowerCase().includes(search) || p.crimeType.toLowerCase().includes(search);
            const matchStatus = !status || p.status === status;
            const matchSec = !security || p.securityLevel === security;
            const matchBlock = !block || p.blockNumber === block;
            const matchCrime = !crime || p.crimeType === crime;
            return matchSearch && matchStatus && matchSec && matchBlock && matchCrime;
        });

        sortData();
        currentPage = 1;
        renderTable();
    }

    function sortData() {
        filteredPrisoners.sort((a, b) => {
            let va = a[sortCol] || '', vb = b[sortCol] || '';
            if (typeof va === 'number') return sortDir === 'asc' ? va - vb : vb - va;
            return sortDir === 'asc' ? va.localeCompare(vb) : vb.localeCompare(va);
        });
    }

    function sortTable(col) {
        if (sortCol === col) sortDir = sortDir === 'asc' ? 'desc' : 'asc';
        else { sortCol = col; sortDir = 'asc'; }
        document.querySelectorAll('.data-table th').forEach(th => {
            th.classList.remove('sort-asc', 'sort-desc');
            if (th.dataset.col === col) th.classList.add('sort-' + sortDir);
        });
        sortData();
        renderTable();
    }

    function renderTable() {
        const perPage = parseInt(document.getElementById('perPage').value);
        const start = (currentPage - 1) * perPage;
        const pageData = filteredPrisoners.slice(start, start + perPage);
        const tbody = document.getElementById('prisonerTbody');

        document.getElementById('resultsCount').textContent =
            filteredPrisoners.length + ' prisoner' + (filteredPrisoners.length !== 1 ? 's' : '') + ' found';

        if (pageData.length === 0) {
            tbody.innerHTML = `<tr><td colspan="11"><div class="empty-state">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <h3>No prisoners found</h3>
                <p>Try adjusting your search or filter criteria</p>
            </div></td></tr>`;
        } else {
            tbody.innerHTML = pageData.map(function(p) {
                var securityClass = (p.securityLevel || '').toLowerCase();
                var statusClass = (p.status || '').toLowerCase();
                var sentenceLabel = p.sentenceYears + ' yr' + (p.sentenceYears !== 1 ? 's' : '');
                return '<tr>' +
                    '<td><input type="checkbox" class="cb row-cb" value="' + p.prisonerId + '" onchange="updateBulkBtn()"></td>' +
                    '<td>' + renderThumb(p) + '</td>' +
                    '<td><a href="javascript:void(0)" onclick="openPrisonerModal(\'' + p.prisonerId + '\')">' + p.prisonerId + '</a></td>' +
                    '<td style="font-weight:500">' + p.fullName + '</td>' +
                    '<td>' + p.crimeType + '</td>' +
                    '<td>' + sentenceLabel + '</td>' +
                    '<td>Block ' + p.blockNumber + '</td>' +
                    '<td><span class="sec-' + securityClass + '">' + p.securityLevel + '</span></td>' +
                    '<td style="color:var(--text-sub);font-size:12.5px">' + p.admissionDate + '</td>' +
                    '<td><span class="badge badge-' + statusClass + '">' + p.status + '</span></td>' +
                    '<td><div class="action-btns">' +
                    '<button type="button" class="action-btn view" title="View" onclick="openPrisonerModal(\'' + p.prisonerId + '\')">' +
                    '<svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>' +
                    '</button>' +
                    '</div></td>' +
                    '</tr>';
            }).join('');
        }

        renderPagination(perPage);
    }

    function renderPagination(perPage) {
        const total = filteredPrisoners.length;
        const totalPages = Math.ceil(total / perPage);
        const start = (currentPage - 1) * perPage + 1;
        const end = Math.min(currentPage * perPage, total);
        document.getElementById('paginationInfo').textContent =
            total > 0 ? 'Showing ' + start + '–' + end + ' of ' + total : '';
        const btns = document.getElementById('paginationBtns');
        let html = '<button class="page-btn" onclick="goPage(' + (currentPage - 1) + ')" ' + (currentPage === 1 ? 'disabled' : '') + '>‹</button>';
        for (let i = 1; i <= totalPages; i++) {
            if (i === 1 || i === totalPages || (i >= currentPage-1 && i <= currentPage+1)) {
                html += '<button class="page-btn ' + (i === currentPage ? 'active' : '') + '" onclick="goPage(' + i + ')">' + i + '</button>';
            } else if (i === currentPage-2 || i === currentPage+2) {
                html += '<span class="page-btn" style="cursor:default;border:none">…</span>';
            }
        }
        html += '<button class="page-btn" onclick="goPage(' + (currentPage + 1) + ')" ' + (currentPage === totalPages || totalPages === 0 ? 'disabled' : '') + '>›</button>';
        btns.innerHTML = html;
    }

    function renderThumb(p) {
        if (p.photoDataUri) {
            return '<img class="prisoner-photo" src="' + p.photoDataUri + '" alt="photo">';
        }
        return '<div style="width:46px;height:46px;border-radius:12px;border:1px solid var(--border);background:linear-gradient(135deg,#f7f9fd,#e8edf7);display:flex;align-items:center;justify-content:center;color:var(--text-light)">' +
            '<svg viewBox="0 0 24 24" style="width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5h16v14H4z"/><circle cx="12" cy="10" r="3"/><path d="M4 17l5-5 4 4 3-3 4 4"/></svg>' +
            '</div>';
    }

    function goPage(p) {
        const perPage = parseInt(document.getElementById('perPage').value);
        const totalPages = Math.ceil(filteredPrisoners.length / perPage);
        if (p < 1 || p > totalPages) return;
        currentPage = p;
        renderTable();
    }

    function clearFilters() {
        document.getElementById('searchInput').value = '';
        document.getElementById('filterStatus').value = '';
        document.getElementById('filterSecurity').value = '';
        document.getElementById('filterBlock').value = '';
        document.getElementById('filterCrime').value = '';
        applyFilters();
    }

    function toggleSelectAll(cb) {
        document.querySelectorAll('.row-cb').forEach(c => c.checked = cb.checked);
        updateBulkBtn();
    }

    function updateBulkBtn() {
        const checked = document.querySelectorAll('.row-cb:checked').length;
        document.getElementById('bulkDeleteBtn').style.display = checked > 0 ? 'inline-flex' : 'none';
        document.getElementById('selectAll').indeterminate = checked > 0 && checked < document.querySelectorAll('.row-cb').length;
    }

    function bulkDelete() {
        const ids = [...document.querySelectorAll('.row-cb:checked')].map(c => c.value);
        if (!ids.length) return;
        if (!confirm('Move ' + ids.length + ' prisoner(s) to trash?')) return;
        fetch('<%= contextPath %>/prisoner-list', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=bulkDelete&ids=' + ids.join(',')
        }).then(() => window.location.reload());
    }

    function openDeleteModal(id) {
        deleteTargetId = id;
        document.getElementById('deleteModal').classList.add('show');
    }

    function closeModal() {
        document.getElementById('deleteModal').classList.remove('show');
        deleteTargetId = null;
    }

    function confirmDelete() {
        if (!deleteTargetId) return;
        fetch('<%= contextPath %>/prisoner-list', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=softDelete&prisonerId=' + deleteTargetId
        }).then(() => { closeModal(); window.location.reload(); });
    }

    function openPrisonerModal(prisonerId) {
        selectedPrisoner = allPrisoners.find(function(p) {
            return p.prisonerId === prisonerId;
        }) || null;
        if (!selectedPrisoner) return;
        fillPrisonerModal(selectedPrisoner);
        closeEditMode();
        document.getElementById('prisonerModal').classList.add('show');
    }

    function fillPrisonerModal(p) {
        document.getElementById('modalTitle').textContent = (p.fullName || 'Prisoner') + ' - ' + (p.prisonerId || '');
        document.getElementById('viewPrisonerId').textContent = p.prisonerId || '-';
        var viewPhoto = document.getElementById('viewPhoto');
        if (p.photoDataUri) {
            viewPhoto.src = p.photoDataUri;
            viewPhoto.style.display = 'block';
        } else {
            viewPhoto.removeAttribute('src');
            viewPhoto.style.display = 'none';
        }
        document.getElementById('viewFullName').textContent = p.fullName || '-';
        document.getElementById('viewDateOfBirth').textContent = p.dateOfBirth || '-';
        document.getElementById('viewGender').textContent = p.gender || '-';
        document.getElementById('viewCrimeType').textContent = p.crimeType || '-';
        document.getElementById('viewSentenceYears').textContent = p.sentenceYears ? p.sentenceYears + ' years' : '-';
        document.getElementById('viewAdmissionDate').textContent = p.admissionDate || '-';
        document.getElementById('viewReleaseDate').textContent = p.releaseDate || '-';
        document.getElementById('viewBlockNumber').textContent = p.blockNumber || '-';
        document.getElementById('viewSecurityLevel').textContent = p.securityLevel || '-';
        document.getElementById('viewStatus').textContent = p.status || '-';
        document.getElementById('viewEmergencyContact').textContent = p.emergencyContact || '-';

        document.getElementById('editPrisonerId').value = p.prisonerId || '';
        document.getElementById('editFullName').value = p.fullName || '';
        document.getElementById('editDateOfBirth').value = p.dateOfBirth || '';
        document.getElementById('editGender').value = p.gender || 'Male';
        document.getElementById('editCrimeType').value = p.crimeType || '';
        document.getElementById('editSentenceYears').value = p.sentenceYears || '';
        document.getElementById('editAdmissionDate').value = p.admissionDate || '';
        document.getElementById('editReleaseDate').value = p.releaseDate || '';
        document.getElementById('editBlockNumber').value = p.blockNumber || '';
        document.getElementById('editSecurityLevel').value = p.securityLevel || 'Low';
        document.getElementById('editStatus').value = p.status || 'Active';
        document.getElementById('editEmergencyContact').value = p.emergencyContact || '';
    }

    function openEditMode() {
        document.getElementById('detailsView').classList.remove('show');
        document.getElementById('editForm').classList.add('show');
    }

    function closeEditMode() {
        document.getElementById('editForm').classList.remove('show');
        document.getElementById('detailsView').classList.add('show');
    }

    function cancelEditMode() {
        closeEditMode();
    }

    function closePrisonerModal() {
        document.getElementById('prisonerModal').classList.remove('show');
        selectedPrisoner = null;
        closeEditMode();
    }

    function saveEdit(e) {
        e.preventDefault();
        if (!selectedPrisoner) return;

        const payload = new URLSearchParams(new FormData(document.getElementById('editForm')));
        payload.set('action', 'update');

        fetch('<%= contextPath %>/prisoner-list', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            body: payload.toString()
        }).then(function(resp) {
            if (!resp.ok) {
                throw new Error('save failed');
            }
            return resp.json();
        }).then(function() {
            window.location.reload();
        }).catch(function() {
            alert('Unable to save changes right now.');
        });
    }

    function deleteFromModal() {
        if (!selectedPrisoner) return;
        deleteTargetId = selectedPrisoner.prisonerId;
        closePrisonerModal();
        document.getElementById('deleteModal').classList.add('show');
    }

    function exportCSV() {
        window.location.href = '<%= contextPath %>/prisoner-list?action=export';
    }

    function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('overlay').classList.add('show'); }
    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('overlay').classList.remove('show'); }

    applyFilters();
</script>
</body>
</html>
