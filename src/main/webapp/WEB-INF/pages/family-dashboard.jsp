<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.User" %>
<%@ page import="com.anjal.service.FamilyDashboardService.*" %>

<%
String contextPath = request.getContextPath();
User user = (User) session.getAttribute("loggedInUser");
String familyName = (user != null) ? user.getFullName() : "Family Member";

// Data from controller
Integer upcomingVisits = (Integer) request.getAttribute("upcomingVisits");
Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
Integer unreadNotifications = (Integer) request.getAttribute("unreadNotifications");
String nextVisitDate = (String) request.getAttribute("nextVisitDate");

List<Prisoner> linkedPrisoners = (List<Prisoner>) request.getAttribute("linkedPrisoners");
List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");

if (upcomingVisits == null) upcomingVisits = 0;
if (pendingRequests == null) pendingRequests = 0;
if (unreadNotifications == null) unreadNotifications = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Family Dashboard | PMS Nepal</title>
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

        /* ── Main ── */
        .main-wrapper{margin-left:var(--sidebar-w);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{height:var(--header-h);background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px;gap:16px;position:sticky;top:0;z-index:50}
        .topbar-title{font-size:16px;font-weight:600}
        .topbar-right{margin-left:auto;display:flex;align-items:center;gap:12px}

        .page-content{padding:28px;flex:1}
        .page-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:28px}
        .page-header h1{font-size:22px;font-weight:600}

        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border-radius:var(--radius-sm);font-size:13px;font-weight:500;cursor:pointer;text-decoration:none;transition:all var(--transition);border:none}
        .btn-primary{background:linear-gradient(135deg,var(--navy),var(--blue-acc));color:#fff}

        /* ── Stats ── */
        .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:28px}
        .stat-card{background:var(--white);border-radius:var(--radius);padding:20px;border:1px solid var(--border-light);box-shadow:0 2px 8px rgba(26,39,68,.05)}
        .stat-value{font-size:24px;font-weight:600;color:var(--text-main);margin-bottom:4px}
        .stat-label{font-size:12px;color:var(--text-sub);text-transform:uppercase;letter-spacing:.05em}

        /* ── Prisoner Profile ── */
        .prisoner-profile{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);padding:28px;margin-bottom:28px;box-shadow:0 4px 12px rgba(26,39,68,.05)}
        .profile-header{display:flex;gap:28px;margin-bottom:28px;align-items:center;border-bottom:1px solid var(--border-light);padding-bottom:24px}
        .profile-photo{width:140px;height:170px;background:var(--cloud);border-radius:var(--radius-sm);overflow:hidden;border:1px solid var(--border);display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .profile-photo img{width:100%;height:100%;object-fit:cover}
        .profile-photo svg{width:60px;stroke:var(--text-light);fill:none}
        
        .profile-title h2{font-size:24px;font-family:'Playfair Display',serif;margin-bottom:4px}
        .profile-title p{font-size:14px;color:var(--text-sub)}
        .status-badge{display:inline-block;padding:4px 12px;border-radius:20px;font-size:11px;font-weight:600;text-transform:uppercase;margin-top:12px}
        
        .details-grid{display:grid;grid-template-columns:repeat(auto-fit, minmax(200px, 1fr));gap:20px}
        .detail-item{padding:12px;background:var(--cloud);border-radius:var(--radius-sm);border:1px solid var(--border-light)}
        .detail-label{font-size:10px;color:var(--text-light);text-transform:uppercase;letter-spacing:.08em;margin-bottom:4px}
        .detail-value{font-size:14px;font-weight:500;color:var(--text-main)}

        .medical-section{margin-top:24px;padding:20px;background:var(--success-bg);border-radius:var(--radius-sm);border:1px solid var(--success-border)}
        .medical-title{font-size:13px;font-weight:600;color:var(--success);margin-bottom:8px;display:flex;align-items:center;gap:6px}
        .medical-notes{font-size:13px;color:var(--success);line-height:1.5}

        /* ── Sidebar & Layout Grid ── */
        .content-grid{display:grid;grid-template-columns:1fr 320px;gap:24px}
        .sidebar-card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);padding:20px}
        .sidebar-card h3{font-size:14px;margin-bottom:16px}
        
        .notif-item{padding:12px 0;border-bottom:1px solid var(--border-light)}
        .notif-item:last-child{border-bottom:none}
        .notif-msg{font-size:13px;margin-bottom:4px}
        .notif-time{font-size:11px;color:var(--text-light)}

        @media(max-width:1100px){.content-grid{grid-template-columns:1fr}}
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
            <a href="<%= contextPath %>/family-dashboard" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Dashboard
            </a>
            <a href="<%= contextPath %>/family/request-visit" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                My Visits
            </a>
            <a href="#" class="nav-item">
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
        <div class="topbar">
            <div class="topbar-title">Family Portal Overview</div>
            <div class="topbar-right">
                <div style="display:flex; align-items:center; gap:20px; margin-right:20px">
                    <div style="text-align:right">
                        <div style="font-size:12px; font-weight:600"><%= familyName %></div>
                        <div style="font-size:10px; color:var(--text-light)">Nepal Prison Service</div>
                    </div>
                </div>
                <a href="<%= contextPath %>/family/request-visit" class="btn btn-primary">Request New Visit</a>
                <a href="<%= contextPath %>/logout" class="btn" style="background:var(--error-bg); color:var(--error); margin-left:8px">Logout</a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1>Welcome back, <%= familyName.split(" ")[0] %></h1>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value"><%= upcomingVisits %></div>
                    <div class="stat-label">Upcoming Visits</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= pendingRequests %></div>
                    <div class="stat-label">Pending Requests</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color:var(--blue-acc)"><%= nextVisitDate %></div>
                    <div class="stat-label">Next Visit</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= unreadNotifications %></div>
                    <div class="stat-label">New Alerts</div>
                </div>
            </div>

            <div class="content-grid">
                <div>
                    <% if(linkedPrisoners != null && !linkedPrisoners.isEmpty()) { 
                        for(Prisoner p : linkedPrisoners) { %>
                        <div class="prisoner-profile">
                            <div class="profile-header">
                                <div class="profile-photo">
                                    <% if(p.getPhotoDataUri() != null && !p.getPhotoDataUri().isEmpty()) { %>
                                        <img src="<%= p.getPhotoDataUri() %>" alt="Prisoner Photo">
                                    <% } else { %>
                                        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    <% } %>
                                </div>
                                <div class="profile-title">
                                    <h2><%= p.getFullName() %></h2>
                                    <p>Prisoner ID: <strong><%= p.getPrisonerId() %></strong></p>
                                    <span class="status-badge" style="background:var(--success-bg);color:var(--success)">Status: <%= p.getStatus() %></span>
                                    <span class="status-badge" style="background:var(--info-bg);color:var(--info);margin-left:8px"><%= p.getSecurityLevel() %> Security</span>
                                </div>
                            </div>

                            <div class="details-grid">
                                <div class="detail-item"><div class="detail-label">Gender</div><div class="detail-value"><%= p.getGender() %></div></div>
                                <div class="detail-item"><div class="detail-label">Date of Birth</div><div class="detail-value"><%= p.getDateOfBirth() %></div></div>
                                <div class="detail-item"><div class="detail-label">Admission Date</div><div class="detail-value"><%= p.getAdmissionDate() %></div></div>
                                <div class="detail-item"><div class="detail-label">Expected Release</div><div class="detail-value"><%= p.getReleaseDate() %></div></div>
                                <div class="detail-item"><div class="detail-label">Block Number</div><div class="detail-value">Block <%= p.getBlockNumber() %></div></div>
                                <div class="detail-item"><div class="detail-label">Crime Type</div><div class="detail-value"><%= p.getCrimeType() %></div></div>
                                <div class="detail-item"><div class="detail-label">Sentence Duration</div><div class="detail-value"><%= p.getSentenceYears() %> Years</div></div>
                                <div class="detail-item"><div class="detail-label">Emergency Contact</div><div class="detail-value"><%= p.getEmergencyContact() != null ? p.getEmergencyContact() : "N/A" %></div></div>
                                <div class="detail-item"><div class="detail-label">Health Condition</div><div class="detail-value"><%= p.getHealthStatus() %></div></div>
                            </div>

                            <% if(p.getMedicalNotes() != null && !p.getMedicalNotes().isEmpty()) { %>
                            <div class="medical-section">
                                <div class="medical-title">
                                    <svg viewBox="0 0 24 24" style="width:14px;stroke:currentColor;fill:none;stroke-width:2.5"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                    Medical & Health Notes
                                </div>
                                <div class="medical-notes"><%= p.getMedicalNotes() %></div>
                            </div>
                            <% } %>\
                        </div>
                    <% } } else { %>
                        <div class="prisoner-profile">
                            <p style="text-align:center;padding:40px;color:var(--text-light)">No linked prisoner records found.</p>
                        </div>
                    <% } %>
                </div>

                <div>
                    <div class="sidebar-card">
                        <h3>Recent Notifications</h3>
                        <div class="notif-list">
                            <% if(notifications == null || notifications.isEmpty()) { %>
                                <p style="font-size:12px;color:var(--text-light);text-align:center;padding:20px">No notifications</p>
                            <% } else { 
                                for(Notification n : notifications) { %>
                                <div class="notif-item">
                                    <div class="notif-msg"><%= n.getMessage() %></div>
                                    <div class="notif-time"><%= n.getTimeAgo() %></div>
                                </div>
                            <% } } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
