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
    // If editing, prisonerId will be a request attribute set by servlet
    String prisonerId = (String) request.getAttribute("prisonerId");
    boolean isEdit = (prisonerId != null && !prisonerId.isEmpty());
    String pageTitle = isEdit ? "Edit Prisoner" : "Add Prisoner";

    // Pre-fill values for edit mode
    String fullName = request.getAttribute("fullName") != null ? (String) request.getAttribute("fullName") : "";
    String dob = request.getAttribute("dateOfBirth") != null ? (String) request.getAttribute("dateOfBirth") : "";
    String gender = request.getAttribute("gender") != null ? (String) request.getAttribute("gender") : "";
    String crimeType = request.getAttribute("crimeType") != null ? (String) request.getAttribute("crimeType") : "";
    String sentenceYears = request.getAttribute("sentenceYears") != null ? String.valueOf(request.getAttribute("sentenceYears")) : "";
    String admissionDate = request.getAttribute("admissionDate") != null ? (String) request.getAttribute("admissionDate") : "";
    String releaseDate = request.getAttribute("releaseDate") != null ? (String) request.getAttribute("releaseDate") : "";
    String blockNumber = request.getAttribute("blockNumber") != null ? (String) request.getAttribute("blockNumber") : "";
    String securityLevel = request.getAttribute("securityLevel") != null ? (String) request.getAttribute("securityLevel") : "";
    String status = request.getAttribute("status") != null ? (String) request.getAttribute("status") : "Active";
    String emergencyContact = request.getAttribute("emergencyContact") != null ? (String) request.getAttribute("emergencyContact") : "";
    String photoDataUri = request.getAttribute("photoDataUri") != null ? (String) request.getAttribute("photoDataUri") : "";
    String errorMsg = (String) request.getAttribute("errorMsg");
    String successMsg = (String) request.getAttribute("successMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--navy:#1a2744;--navy-mid:#243358;--blue-acc:#3a6fd8;--blue-light:#4f85ec;--steel:#5a7099;--mist:#e8edf7;--cloud:#f4f6fb;--white:#ffffff;--border:#d0d9ee;--border-light:#e8edf7;--text-main:#1a2744;--text-sub:#5a7099;--text-light:#8e9ec1;--success:#1e7d5a;--success-bg:#edf7f3;--warn:#b07d10;--warn-bg:#fdf8ea;--error:#c94040;--error-bg:#fef2f2;--error-border:#f5c0c0;--info:#2a5fa5;--info-bg:#eef4fd;--sidebar-w:260px;--header-h:64px;--shadow-sm:0 2px 8px rgba(26,39,68,.07);--shadow-md:0 4px 16px rgba(26,39,68,.10);--radius:12px;--radius-sm:8px;--transition:.2s ease}
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}
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
        .nav-badge{margin-left:auto;background:rgba(217,79,79,.85);color:#fff;font-size:10px;font-weight:600;padding:2px 7px;border-radius:20px}
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
        .breadcrumb{display:flex;align-items:center;gap:6px;font-size:12px;color:var(--text-light)}
        .breadcrumb a{color:var(--blue-acc);text-decoration:none}
        .breadcrumb a:hover{text-decoration:underline}
        .page-content{padding:28px;flex:1;max-width:900px}
        .page-header{margin-bottom:24px}
        .page-header h1{font-size:22px;font-weight:600;color:var(--text-main)}
        .page-header p{font-size:13px;color:var(--text-sub);margin-top:3px}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border-radius:var(--radius-sm);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;text-decoration:none;transition:all var(--transition);border:none}
        .btn-primary{background:linear-gradient(135deg,var(--navy),var(--blue-acc));color:#fff;box-shadow:0 3px 10px rgba(58,111,216,.30)}
        .btn-primary:hover{opacity:.9}
        .btn-primary:disabled{background:linear-gradient(135deg,#aab4cc,#c2cde0);cursor:not-allowed;box-shadow:none}
        .btn-secondary{background:var(--white);color:var(--text-main);border:1px solid var(--border)}
        .btn-secondary:hover{background:var(--cloud)}
        .btn svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:2}
        .alert{display:flex;align-items:flex-start;gap:9px;padding:12px 16px;border-radius:var(--radius-sm);margin-bottom:20px;font-size:13px;line-height:1.5}
        .alert svg{width:15px;height:15px;flex-shrink:0;margin-top:1px;fill:none}
        .alert-error{background:var(--error-bg);border:1px solid var(--error-border);color:var(--error)}
        .alert-error svg{stroke:var(--error)}
        /* ── Form sections ── */
        .form-card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);box-shadow:var(--shadow-sm);margin-bottom:20px;overflow:hidden}
        .form-section-header{padding:16px 24px;border-bottom:1px solid var(--border-light);display:flex;align-items:center;gap:10px}
        .form-section-header h3{font-size:14px;font-weight:600;color:var(--text-main)}
        .form-section-header svg{width:16px;height:16px;fill:none;stroke:var(--blue-acc);stroke-width:1.8}
        .form-body{padding:24px}
        .form-grid{display:grid;gap:18px}
        .form-grid-2{grid-template-columns:1fr 1fr}
        .form-grid-3{grid-template-columns:1fr 1fr 1fr}
        .field-group{display:flex;flex-direction:column;gap:6px}
        label{font-size:12.5px;font-weight:500;color:var(--text-sub)}
        .required{color:var(--error);margin-left:2px}
        .input-wrap{position:relative;display:flex;align-items:center}
        .input-icon{position:absolute;left:11px;width:15px;height:15px;stroke:var(--text-light);stroke-width:1.7;fill:none;pointer-events:none;transition:stroke var(--transition)}
        .field-group:focus-within .input-icon{stroke:var(--blue-acc)}
        input[type="text"],input[type="date"],input[type="number"],input[type="tel"],select,textarea{width:100%;padding:10px 12px 10px 36px;font-family:inherit;font-size:13.5px;color:var(--text-main);background:var(--cloud);border:1.5px solid var(--border);border-radius:var(--radius-sm);outline:none;transition:border-color var(--transition),box-shadow var(--transition),background var(--transition)}
        input.no-icon,select.no-icon{padding-left:12px}
        textarea.no-icon{padding-left:12px}
        select{appearance:none}
        textarea{resize:vertical;min-height:80px}
        input::placeholder,textarea::placeholder{color:var(--text-light);font-size:13px}
        input:focus,select:focus,textarea:focus{border-color:var(--blue-acc);background:var(--white);box-shadow:0 0 0 3px rgba(58,111,216,.10)}
        input.invalid,select.invalid,textarea.invalid{border-color:var(--error)!important;background:var(--error-bg)!important}
        .select-arrow{position:absolute;right:10px;pointer-events:none;width:14px;height:14px;stroke:var(--text-light);fill:none;stroke-width:2}
        .field-error{font-size:11.5px;color:var(--error);display:none;align-items:center;gap:5px}
        .field-error.show{display:flex}
        .field-error svg{width:12px;height:12px;stroke:var(--error);fill:none;flex-shrink:0}
        .field-hint{font-size:11.5px;color:var(--text-light)}
        .photo-wrap{display:flex;align-items:center;gap:16px;padding:14px;border:1px dashed var(--border);border-radius:12px;background:rgba(232,237,247,.55)}
        .photo-preview{width:72px;height:72px;border-radius:14px;object-fit:cover;border:1px solid var(--border);background:linear-gradient(135deg,#f7f9fd,#e8edf7)}
        .photo-fallback{width:72px;height:72px;border-radius:14px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#f7f9fd,#e8edf7);border:1px solid var(--border);color:var(--text-light)}
        .photo-fallback svg{width:28px;height:28px;stroke:currentColor;fill:none;stroke-width:1.8}
        /* ── Form actions ── */
        .form-actions{display:flex;gap:12px;align-items:center;padding:20px 0;border-top:1px solid var(--border-light);margin-top:4px;flex-wrap:wrap}
        .spinner{display:none;width:16px;height:16px;border:2px solid rgba(255,255,255,.4);border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite}
        @keyframes spin{to{transform:rotate(360deg)}}
        @media(max-width:700px){.form-grid-2,.form-grid-3{grid-template-columns:1fr}.page-content{padding:16px}.main-wrapper{margin-left:0}}
    </style>
</head>
<body>
<div class="layout">
    <nav class="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <div class="logo-text"><h2>PMS Nepal</h2><p><%= "ADMIN".equals(role) ? "Admin" : "Staff" %></p></div>
            </div>
        </div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/admin-dashboard" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg> Dashboard</a>
            
            <p class="nav-section-label" style="margin-top:8px">Management</p>
            <a href="<%= contextPath %>/prisoner-list" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg> Prisoners</a>
            <a href="staff-management.jsp" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg> Staff</a>
            <a href="<%= contextPath %>/family-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg> Family Members</a>

            <p class="nav-section-label" style="margin-top:8px">Operations</p>
            <a href="<%= contextPath %>/admin/visit-management" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg> Visit Requests</a>
            <a href="<%= contextPath %>/trash" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg> Trash / Restore</a>
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
            <div>
                <div class="topbar-title"><%= pageTitle %></div>
                <div class="breadcrumb">
                    <a href="<%= contextPath %>/prisoner-list">Prisoners</a>
                    <span>›</span><span><%= pageTitle %></span>
                </div>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1><%= pageTitle %></h1>
                <p><%= isEdit ? "Update prisoner information and records" : "Register a new prisoner into the system" %></p>
            </div>

            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="alert alert-error">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span><%= errorMsg %></span>
            </div>
            <% } %>

            <% if (successMsg != null && !successMsg.isEmpty()) { %>
            <div class="alert" style="background:var(--success-bg);border:1px solid var(--success-border);color:var(--success)">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                <span><%= successMsg %></span>
            </div>
            <% } %>

            <form id="prisonerForm" action="<%= contextPath %>/add-prisoner" method="POST" enctype="multipart/form-data" novalidate>
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">
                <% if (isEdit) { %><input type="hidden" name="prisonerId" value="<%= prisonerId %>"><% } %>

                <!-- Personal Information -->
                <div class="form-card">
                    <div class="form-section-header">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        <h3>Personal Information</h3>
                    </div>
                    <div class="form-body">
                        <div class="form-grid form-grid-2">
                            <div class="field-group">
                                <label>Full Name <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    <input type="text" name="fullName" id="fullName" value="<%= fullName %>" placeholder="Full legal name" required>
                                </div>
                                <span class="field-error" id="fullNameErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Name cannot contain numbers or be empty</span>
                            </div>
                            <div class="field-group">
                                <label>Date of Birth <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                    <input type="date" name="dateOfBirth" id="dateOfBirth" value="<%= dob %>" required>
                                </div>
                                <span class="field-error" id="dobErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Date of birth is required</span>
                            </div>
                            <div class="field-group">
                                <label>Gender <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><line x1="12" y1="2" x2="12" y2="8"/><line x1="12" y1="16" x2="12" y2="22"/><line x1="8" y1="6" x2="16" y2="6"/><line x1="9" y1="19" x2="15" y2="19"/></svg>
                                    <select name="gender" id="gender" required>
                                        <option value="">Select gender</option>
                                        <option value="Male" <%= "Male".equals(gender)?"selected":"" %>>Male</option>
                                        <option value="Female" <%= "Female".equals(gender)?"selected":"" %>>Female</option>
                                        <option value="Other" <%= "Other".equals(gender)?"selected":"" %>>Other</option>
                                    </select>
                                    <svg class="select-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <span class="field-error" id="genderErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Please select a gender</span>
                            </div>
                            <div class="field-group">
                                <label>Emergency Contact</label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.55 2h3a2 2 0 0 1 2 1.72"/></svg>
                                    <input type="tel" name="emergencyContact" value="<%= emergencyContact %>" placeholder="98XXXXXXXX">
                                </div>
                                <span class="field-hint">Optional — next of kin contact number</span>
                            </div>
                            <div class="field-group form-grid-2">
                                <label>Photo</label>
                                <div class="photo-wrap">
                                    <%
                                        if (photoDataUri != null && !photoDataUri.isEmpty()) {
                                    %>
                                    <img id="photoPreview" class="photo-preview" src="<%= photoDataUri %>" alt="Prisoner photo">
                                    <%
                                        } else {
                                    %>
                                    <div id="photoPreview" class="photo-fallback">
                                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5h16v14H4z"/><circle cx="12" cy="10" r="3"/><path d="M4 17l5-5 4 4 3-3 4 4"/></svg>
                                    </div>
                                    <%
                                        }
                                    %>
                                    <div style="flex:1">
                                        <input type="file" name="photo" id="photoInput" accept="image/*" style="padding-left:0;background:transparent;border:none">
                                        <span class="field-hint" style="display:block;margin-top:6px">Upload a small passport-style image. JPG, PNG, GIF, or WEBP.</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Criminal Record -->
                <div class="form-card">
                    <div class="form-section-header">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        <h3>Criminal Record</h3>
                    </div>
                    <div class="form-body">
                        <div class="form-grid form-grid-3">
                            <div class="field-group">
                                <label>Crime Type <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
                                    <select name="crimeType" required>
                                        <option value="">Select crime type</option>
                                        <option value="Murder" <%= "Murder".equals(crimeType)?"selected":"" %>>Murder</option>
                                        <option value="Robbery" <%= "Robbery".equals(crimeType)?"selected":"" %>>Robbery</option>
                                        <option value="Fraud" <%= "Fraud".equals(crimeType)?"selected":"" %>>Fraud</option>
                                        <option value="Drug Trafficking" <%= "Drug Trafficking".equals(crimeType)?"selected":"" %>>Drug Trafficking</option>
                                        <option value="Assault" <%= "Assault".equals(crimeType)?"selected":"" %>>Assault</option>
                                        <option value="Kidnapping" <%= "Kidnapping".equals(crimeType)?"selected":"" %>>Kidnapping</option>
                                        <option value="Terrorism" <%= "Terrorism".equals(crimeType)?"selected":"" %>>Terrorism</option>
                                        <option value="Other" <%= "Other".equals(crimeType)?"selected":"" %>>Other</option>
                                    </select>
                                    <svg class="select-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <span class="field-error" id="crimeErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Crime type is required</span>
                            </div>
                            <div class="field-group">
                                <label>Sentence (Years) <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    <input type="number" name="sentenceYears" id="sentenceYears" value="<%= sentenceYears %>" min="1" max="99" placeholder="e.g. 10" required>
                                </div>
                                <span class="field-error" id="sentenceErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Enter a valid sentence (1–99 years)</span>
                            </div>
                            <div class="field-group">
                                <label>Status <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="20 6 9 17 4 12"/></svg>
                                    <select name="status" required>
                                        <option value="Active" <%= "Active".equals(status)?"selected":"" %>>Active</option>
                                        <option value="Released" <%= "Released".equals(status)?"selected":"" %>>Released</option>
                                        <option value="Transferred" <%= "Transferred".equals(status)?"selected":"" %>>Transferred</option>
                                    </select>
                                    <svg class="select-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                            </div>
                        </div>
                        <div class="form-grid form-grid-2" style="margin-top:18px">
                            <div class="field-group">
                                <label>Admission Date <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                    <input type="date" name="admissionDate" id="admissionDate" value="<%= admissionDate %>" required>
                                </div>
                                <span class="field-error" id="admissionErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Admission date is required</span>
                            </div>
                            <div class="field-group">
                                <label>Expected Release Date</label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                    <input type="date" name="releaseDate" id="releaseDate" value="<%= releaseDate %>">
                                </div>
                                <span class="field-hint">Auto-calculated if left blank</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cell Assignment -->
                <div class="form-card">
                    <div class="form-section-header">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                        <h3>Cell Assignment</h3>
                    </div>
                    <div class="form-body">
                        <div class="form-grid form-grid-2">
                            <div class="field-group">
                                <label>Block Number <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                                    <select name="blockNumber" id="blockNumber" required>
                                        <option value="">Select block</option>
                                        <option value="A" <%= "A".equals(blockNumber)?"selected":"" %>>Block A</option>
                                        <option value="B" <%= "B".equals(blockNumber)?"selected":"" %>>Block B</option>
                                        <option value="C" <%= "C".equals(blockNumber)?"selected":"" %>>Block C</option>
                                        <option value="D" <%= "D".equals(blockNumber)?"selected":"" %>>Block D</option>
                                        <option value="E" <%= "E".equals(blockNumber)?"selected":"" %>>Block E (High Security)</option>
                                    </select>
                                    <svg class="select-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <span class="field-error" id="blockErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Block assignment is required</span>
                            </div>
                            <div class="field-group">
                                <label>Security Level <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                    <select name="securityLevel" id="securityLevel" required>
                                        <option value="">Select level</option>
                                        <option value="Low" <%= "Low".equals(securityLevel)?"selected":"" %>>Low</option>
                                        <option value="Medium" <%= "Medium".equals(securityLevel)?"selected":"" %>>Medium</option>
                                        <option value="High" <%= "High".equals(securityLevel)?"selected":"" %>>High</option>
                                    </select>
                                    <svg class="select-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <span class="field-error" id="securityErr"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>Security level is required</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Form Actions -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        <div class="spinner" id="spinner"></div>
                        <svg id="saveIcon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        <span id="btnLabel"><%= isEdit ? "Update Prisoner" : "Save Prisoner" %></span>
                    </button>
                    <a href="<%= contextPath %>/prisoner-list" class="btn btn-secondary">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                        Cancel
                    </a>
                    <% if (isEdit) { %>
                    <a href="view-prisoner.jsp?id=<%= prisonerId %>" class="btn btn-secondary" style="margin-left:auto">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        View Record
                    </a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    /* Auto-calculate release date from admission + sentence */
    function calcRelease() {
        const adm = document.getElementById('admissionDate').value;
        const yrs = parseInt(document.getElementById('sentenceYears').value);
        const rel = document.getElementById('releaseDate');
        if (adm && yrs > 0 && !rel.value) {
            const d = new Date(adm);
            d.setFullYear(d.getFullYear() + yrs);
            rel.value = d.toISOString().split('T')[0];
        }
    }
    document.getElementById('admissionDate').addEventListener('change', calcRelease);
    document.getElementById('sentenceYears').addEventListener('change', calcRelease);

    const photoInput = document.getElementById('photoInput');
    if (photoInput) {
        photoInput.addEventListener('change', () => {
            const file = photoInput.files && photoInput.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = () => {
                const preview = document.getElementById('photoPreview');
                preview.outerHTML = '<img id="photoPreview" class="photo-preview" src="' + reader.result + '" alt="Prisoner photo">';
            };
            reader.readAsDataURL(file);
        });
    }

    /* Validation */
    const validations = [
        { id: 'fullName',     errId: 'fullNameErr',  fn: v => v.trim().length >= 2 && !/\d/.test(v) },
        { id: 'dateOfBirth',  errId: 'dobErr',       fn: v => v !== '' },
        { id: 'gender',       errId: 'genderErr',    fn: v => v !== '' },
        { id: 'sentenceYears',errId: 'sentenceErr',  fn: v => /^\d+$/.test(v) && parseInt(v) >= 1 && parseInt(v) <= 99 },
        { id: 'admissionDate',errId: 'admissionErr', fn: v => v !== '' },
        { id: 'blockNumber',  errId: 'blockErr',     fn: v => v !== '' },
        { id: 'securityLevel',errId: 'securityErr',  fn: v => v !== '' },
    ];

    validations.forEach(({id, errId, fn}) => {
        document.getElementById(id).addEventListener('blur', () => {
            const val = document.getElementById(id).value;
            const ok = fn(val);
            document.getElementById(id).classList.toggle('invalid', !ok && val !== '');
            document.getElementById(errId).classList.toggle('show', !ok && val !== '');
        });
    });

    document.getElementById('prisonerForm').addEventListener('submit', function(e) {
        e.preventDefault();
        let valid = true;
        validations.forEach(({id, errId, fn}) => {
            const val = document.getElementById(id).value;
            const ok = fn(val);
            document.getElementById(id).classList.toggle('invalid', !ok);
            document.getElementById(errId).classList.toggle('show', !ok);
            if (!ok) valid = false;
        });
        if (!valid) { document.querySelector('.invalid')?.focus(); return; }
        document.getElementById('spinner').style.display = 'block';
        document.getElementById('saveIcon').style.display = 'none';
        document.getElementById('btnLabel').textContent = 'Saving…';
        document.getElementById('submitBtn').disabled = true;
        this.submit();
    });
</script>
</body>
</html>
