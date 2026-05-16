<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.Prisoner" %>
<%@ page import="com.anjal.model.User" %>

<%
String contextPath = request.getContextPath();
User user = (User) session.getAttribute("loggedInUser");
String familyName = (user != null) ? user.getFullName() : "Family Member";

List<Prisoner> linkedPrisoners = (List<Prisoner>) request.getAttribute("linkedPrisoners");
Prisoner selectedPrisoner = (Prisoner) request.getAttribute("selectedPrisoner");
String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request Visit | Family Portal</title>
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
            --radius:12px;--radius-sm:8px;--transition:.2s ease
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}

        /* ── Sidebar ── */
        .sidebar{
            width:var(--sidebar-w);min-height:100vh;background:var(--navy);
            display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;
            z-index:100;
        }
        .sidebar-logo{padding:20px 24px 16px;border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo-inner{display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:rgba(255,255,255,.12);border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .logo-icon svg{width:18px;height:18px;fill:none;stroke:#fff;stroke-width:1.8}
        .logo-text h2{font-family:'Playfair Display',serif;font-size:14px;font-weight:600;color:#fff;line-height:1.2}
        .logo-text p{font-size:10px;color:rgba(255,255,255,.45);letter-spacing:.08em;text-transform:uppercase}

        .sidebar-nav{flex:1;padding:16px 0;overflow-y:auto}
        .nav-section-label{padding:8px 24px 4px;font-size:10px;color:rgba(255,255,255,.30);letter-spacing:.12em;text-transform:uppercase;font-weight:500}
        .nav-item{display:flex;align-items:center;gap:12px;padding:10px 24px;color:rgba(255,255,255,.65);text-decoration:none;font-size:13px;font-weight:400;border-left:3px solid transparent;transition:all var(--transition)}
        .nav-item:hover{color:#fff;background:rgba(255,255,255,.06)}
        .nav-item.active{color:#fff;background:rgba(58,111,216,.25);border-left-color:var(--blue-light);font-weight:500}
        .nav-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.7}

        .sidebar-footer{padding:16px 24px;border-top:1px solid rgba(255,255,255,.08)}
        .user-info{display:flex;align-items:center;gap:10px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,var(--blue-acc),var(--blue-light));border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:#fff}
        .user-details p{font-size:12.5px;color:#fff;font-weight:500;line-height:1.2}
        .user-details span{font-size:10.5px;color:rgba(255,255,255,.45)}
        .logout-btn{margin-left:auto;background:none;border:none;cursor:pointer;color:rgba(255,255,255,.4);padding:4px;transition:color var(--transition);display:flex}
        .logout-btn:hover{color:rgba(255,255,255,.8)}
        .logout-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:2}

        .main-wrapper{margin-left:var(--sidebar-w);flex:1;display:flex;flex-direction:column;min-height:100vh} 
        .topbar{height:var(--header-h);background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px}        .topbar-title{font-size:16px;font-weight:600}

        .page-content{padding:28px;flex:1;max-width:800px;margin:0 auto}
        .card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);box-shadow:0 2px 8px rgba(26,39,68,.07);padding:28px}
        
        .form-header{margin-bottom:24px}
        .form-header h1{font-size:20px;font-weight:600;margin-bottom:6px}
        .form-header p{font-size:13px;color:var(--text-sub)}

        .form-group{margin-bottom:18px}
        label{display:block;font-size:13px;font-weight:500;margin-bottom:6px;color:var(--text-main)}
        select, input, textarea{
            width:100%;padding:10px 14px;border:1px solid var(--border);border-radius:var(--radius-sm);
            font-family:inherit;font-size:13px;transition:border-color var(--transition);outline:none
        }
        select:focus, input:focus, textarea:focus{border-color:var(--blue-acc)}
        textarea{resize:vertical;min-height:100px}

        .btn{display:inline-flex;align-items:center;justify-content:center;gap:7px;padding:11px 24px;border-radius:var(--radius-sm);font-size:13px;font-weight:500;cursor:pointer;text-decoration:none;transition:all var(--transition);border:none;width:100%}
        .btn-primary{background:linear-gradient(135deg,var(--navy),var(--blue-acc));color:#fff}
        .btn-primary:hover{opacity:.9;transform:translateY(-1px)}
        .btn-secondary{background:var(--white);color:var(--text-main);border:1px solid var(--border);margin-top:10px}

        .error-msg{background:var(--error-bg);color:var(--error);padding:12px;border-radius:var(--radius-sm);font-size:13px;margin-bottom:18px}
    </style>
</head>
<body>

<div class="layout">
    <nav class="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div>
                <div class="logo-text"><h2>Family Portal</h2><p>Prison Management</p></div>
            </div>
        </div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Main Menu</p>
            <a href="<%= contextPath %>/family-dashboard" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Dashboard
            </a>
            <a href="<%= contextPath %>/family/request-visit" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                My Visits
            </a>
            <a href="<%= contextPath %>/family/inquiries" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                Inquiries
            </a>
        </div>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= familyName.substring(0,1).toUpperCase() %></div>
                <div class="user-details"><p><%= familyName %></p><span>Family Member</span></div>
                <a href="<%= contextPath %>/logout" class="logout-btn" title="Logout">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                </a>
            </div>
        </div>
    </nav>

    <div class="main-wrapper">
        <div class="topbar"><div class="topbar-title">Request a Visit</div></div>

        <div class="page-content">
            <div class="card">
                <div class="form-header">
                    <h1>New Visit Request</h1>
                    <p>Fill out the form below to request a meeting with a prisoner.</p>
                </div>

                <% if(error != null) { %>
                    <div class="error-msg"><%= error %></div>
                <% } %>

                <form action="<%= contextPath %>/family/request-visit" method="POST">
                    <div class="form-group">
                        <label>Prisoner</label>
                        <% if(selectedPrisoner != null) { %>
                            <div style="padding:10px 14px; background:var(--cloud); border:1px solid var(--border); border-radius:var(--radius-sm); font-size:13px; font-weight:500; color:var(--text-main)">
                                <%= selectedPrisoner.getFullName() %> (<%= selectedPrisoner.getPrisonerId() %>)
                            </div>
                            <input type="hidden" name="prisonerId" value="<%= selectedPrisoner.getId() %>">
                        <% } else { %>
                            <select name="prisonerId" id="prisonerId" required>
                                <option value="">-- Choose Prisoner --</option>
                                <% if(linkedPrisoners != null) { 
                                    for(Prisoner p : linkedPrisoners) { %>
                                    <option value="<%= p.getId() %>"><%= p.getFullName() %> (<%= p.getPrisonerId() %>)</option>
                                <% } } %>
                            </select>
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label for="preferredDate">Preferred Visit Date</label>
                        <input type="date" name="preferredDate" id="preferredDate" required min="<%= java.time.LocalDate.now().plusDays(1) %>">
                    </div>

                    <div class="form-group">
                        <label for="relation">Relationship to Prisoner</label>
                        <input type="text" name="relation" id="relation" placeholder="e.g. Brother, Mother, Friend" required>
                    </div>

                    <div class="form-group">
                        <label for="message">Message / Reason for Visit (Optional)</label>
                        <textarea name="message" id="message" placeholder="Briefly state why you'd like to visit..."></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary">Submit Visit Request</button>
                    <a href="<%= contextPath %>/family-dashboard" class="btn btn-secondary">Cancel</a>
                </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>
