<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.service.FamilyDashboardService" %>

<%
    String contextPath = request.getContextPath();
    String familyName = (String) request.getAttribute("familyName");
    String initials = (String) request.getAttribute("initials");
    String relationship = (String) request.getAttribute("relationship");
    
    Integer totalRequests = (Integer) request.getAttribute("upcomingVisits") + (Integer) request.getAttribute("approvedVisits") + (Integer) request.getAttribute("pendingRequests");
    Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
    Integer approvedVisits = (Integer) request.getAttribute("approvedVisits");
    String nextVisitDate = (String) request.getAttribute("nextVisitDate");

    List<FamilyDashboardService.VisitRequest> recentVisits = (List<FamilyDashboardService.VisitRequest>) request.getAttribute("recentVisits");
    List<FamilyDashboardService.Notification> notifications = (List<FamilyDashboardService.Notification>) request.getAttribute("recentNotifications");
    
    List<FamilyDashboardService.Prisoner> prisoners = (List<FamilyDashboardService.Prisoner>) request.getAttribute("linkedPrisoners");
    FamilyDashboardService.Prisoner prisoner = (prisoners != null && !prisoners.isEmpty()) ? prisoners.get(0) : null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Family Portal | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744; --navy-mid:#243358; --navy-light:#2e4170;
            --blue-acc:#3a6fd8; --blue-light:#4f85ec; --blue-pale:#e8eef9;
            --steel:#5a7099; --mist:#e8edf7; --cloud:#f4f6fb; --white:#ffffff;
            --border:#d0d9ee; --border-light:#e8edf7;
            --text-main:#1a2744; --text-sub:#5a7099; --text-light:#8e9ec1;
            --success:#1e7d5a; --success-bg:#edf7f3;
            --warn:#b07d10; --warn-bg:#fdf8ea;
            --error:#c94040; --error-bg:#fef2f2;
            --info:#2a5fa5; --info-bg:#eef4fd;
            --sidebar-w:260px; --header-h:70px;
            --shadow-sm:0 2px 8px rgba(26,39,68,.07); --shadow-md:0 4px 16px rgba(26,39,68,.10);
            --radius:12px; --radius-sm:8px; --transition:.2s ease
        }
        body{font-family:'DM Sans',sans-serif; color:var(--text-main); background:var(--cloud); min-height:100vh}
        .layout{display:flex; min-height:100vh}
        
        /* Sidebar */
        .sidebar{
            width:var(--sidebar-w); background:var(--navy); color:#fff;
            display:flex; flex-direction:column; position:fixed; height:100vh; z-index:100;
        }
        .sidebar-logo{padding:24px; border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo h2{font-family:'Playfair Display',serif; font-size:18px}
        .sidebar-logo p{font-size:10px; opacity:0.5; text-transform:uppercase; letter-spacing:1px}
        .sidebar-nav{flex:1; padding:20px 0}
        .nav-section-label{padding:10px 24px; font-size:10px; color:rgba(255,255,255,0.3); text-transform:uppercase; font-weight:600}
        .nav-item{
            display:flex; align-items:center; gap:12px; padding:12px 24px;
            color:rgba(255,255,255,0.7); text-decoration:none; font-size:14px; transition:var(--transition);
        }
        .nav-item:hover, .nav-item.active{color:#fff; background:rgba(255,255,255,0.05)}
        .nav-item.active{border-left:4px solid var(--blue-light); background:rgba(58,111,216,0.1)}
        
        /* Main Content */
        .main-wrapper{margin-left:var(--sidebar-w); flex:1; display:flex; flex-direction:column}
        .topbar{
            height:var(--header-h); background:var(--white); padding:0 30px;
            display:flex; align-items:center; justify-content:space-between;
            border-bottom:1px solid var(--border-light); position:sticky; top:0; z-index:50;
        }
        .topbar-title h1{font-size:18px; font-weight:600}
        .topbar-title p{font-size:12px; color:var(--text-light)}
        
        .page-content{padding:30px}

        /* Prisoner Hero Section */
        .prisoner-hero{
            background: linear-gradient(135deg, var(--navy), var(--navy-mid));
            color: white; padding: 28px; border-radius: var(--radius); margin-bottom: 24px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: var(--shadow-md);
        }
        .pri-info-box{display: flex; align-items: center; gap: 20px;}
        .pri-avatar{
            width: 70px; height: 70px; background: rgba(255,255,255,0.1); 
            border-radius: 15px; display: flex; align-items: center; justify-content: center;
        }
        .pri-details h2{font-size: 22px; margin-bottom: 4px;}
        .pri-details p{font-size: 13px; opacity: 0.7;}
        .pri-tag{
            background: var(--success); color: white; padding: 4px 12px; 
            border-radius: 20px; font-size: 11px; font-weight: 600; margin-left: 10px;
        }

        /* Stats Grid */
        .stats-grid{display:grid; grid-template-columns:repeat(4, 1fr); gap:20px; margin-bottom:24px}
        .stat-card{
            background:var(--white); padding:20px; border-radius:var(--radius);
            border:1px solid var(--border-light); box-shadow:var(--shadow-sm);
        }
        .stat-value{font-size:24px; font-weight:600; color:var(--navy); margin-bottom:4px}
        .stat-label{font-size:12px; color:var(--text-sub); font-weight:500}

        /* Content Columns */
        .content-grid{display:grid; grid-template-columns: 1fr 350px; gap:24px}
        .card{background:var(--white); border-radius:var(--radius); border:1px solid var(--border-light); overflow:hidden; margin-bottom:24px}
        .card-header{padding:18px 24px; border-bottom:1px solid var(--border-light); display:flex; justify-content:space-between; align-items:center}
        .card-header h3{font-size:15px; font-weight:600}

        /* Table */
        .data-table{width:100%; border-collapse:collapse}
        .data-table th{text-align:left; padding:12px 24px; font-size:11px; text-transform:uppercase; color:var(--text-light); background:var(--cloud)}
        .data-table td{padding:14px 24px; font-size:13px; border-bottom:1px solid var(--border-light)}
        
        .badge{padding:4px 10px; border-radius:20px; font-size:11px; font-weight:600}
        .badge-approved{background:var(--success-bg); color:var(--success)}
        .badge-pending{background:var(--warn-bg); color:var(--warn)}
        
        .btn{
            display:inline-flex; align-items:center; gap:8px; padding:12px 24px; 
            border-radius:var(--radius-sm); font-size:14px; font-weight:600; cursor:pointer;
            text-decoration:none; border:none; transition:var(--transition);
        }
        .btn-primary{background:var(--blue-acc); color:#fff}
        .btn-primary:hover{background:var(--blue-light); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(58,111,216,0.3);}

        .action-card {
            background: var(--blue-pale);
            border: 2px dashed var(--blue-acc);
            padding: 25px;
            text-align: center;
            border-radius: var(--radius);
        }
        .action-card h4 { margin-bottom: 10px; color: var(--navy); }
        .action-card p { font-size: 13px; color: var(--text-sub); margin-bottom: 20px; }

        /* Notifications */
        .notif-item{padding:15px 24px; border-bottom:1px solid var(--border-light); display:flex; gap:12px}
        .notif-dot{width:8px; height:8px; border-radius:50%; margin-top:5px; flex-shrink:0}
        .notif-content p{font-size:13px; margin-bottom:4px}
        .notif-content span{font-size:11px; color:var(--text-light)}
        
        @media (max-width: 1100px) {
            .content-grid { grid-template-columns: 1fr; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
    </style>
</head>
<body>

<div class="layout">
    <aside class="sidebar">
        <div class="sidebar-logo">
            <h2>PMS Nepal</h2>
            <p>Family Portal</p>
        </div>
        <nav class="sidebar-nav">
            <p class="nav-section-label">Main Menu</p>
            <a href="#" class="nav-item active">Dashboard</a>
            <a href="<%= contextPath %>/family-prisoner-info" class="nav-item">Prisoner Info</a>
            <a href="<%= contextPath %>/family-request-visit" class="nav-item">Request Visit</a>
            <a href="#" class="nav-item">Visit History</a>
            
            <p class="nav-section-label" style="margin-top:20px">Account</p>
            <a href="#" class="nav-item">Notifications</a>
            <a href="#" class="nav-item">Profile Settings</a>
            <a href="<%= contextPath %>/family-inquiry" class="nav-item">Inquiry / Contact</a>
            <a href="<%= contextPath %>/logout" class="nav-item" style="color:var(--error)">Logout</a>
        </nav>
    </aside>

    <main class="main-wrapper">
        <header class="topbar">
            <div class="topbar-title">
                <h1>Welcome back, <%= familyName %></h1>
                <p>Status for <%= prisoner != null ? prisoner.getFullName() : "Prisoner" %></p>
            </div>
            <div class="topbar-right" style="display:flex; align-items:center; gap:20px;">
                <span id="liveClock" style="font-size: 13px; color: var(--text-sub); font-weight: 500;"></span>
                <a href="<%= contextPath %>/family-request-visit" class="btn btn-primary">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    New Visit Request
                </a>
            </div>
        </header>

        <div class="page-content">
            
            <% if (prisoner != null) { %>
            <div class="prisoner-hero">
                <div class="pri-info-box">
                    <div class="pri-avatar">
                        <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </div>
                    <div class="pri-details">
                        <div style="display:flex; align-items:center">
                            <h2><%= prisoner.getFullName() %></h2>
                            <span class="pri-tag">ELIGIBLE FOR VISIT</span>
                        </div>
                        <p>Prisoner ID: <strong><%= prisoner.getPrisonerId() %></strong> | Block: <strong><%= prisoner.getBlockNumber() %></strong></p>
                    </div>
                </div>
                <div class="pri-actions">
                    <a href="<%= contextPath %>/family-prisoner-info" class="btn" style="background:rgba(255,255,255,0.1); color:white; border:1px solid rgba(255,255,255,0.2)">View Profile</a>
                    <a href="<%= contextPath %>/family-request-visit" class="btn" style="background:white; color:var(--navy); margin-left:10px;">Schedule Visit</a>
                </div>
            </div>
            <% } %>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value"><%= totalRequests %></div>
                    <div class="stat-label">Total Requests</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= pendingRequests %></div>
                    <div class="stat-label">Pending Approval</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color:var(--success)"><%= approvedVisits %></div>
                    <div class="stat-label">Approved Visits</div>
                </div>
                <div class="stat-card" style="background:var(--info-bg); border-color:var(--blue-acc)">
                    <div class="stat-value" style="font-size:16px"><%= nextVisitDate %></div>
                    <div class="stat-label">Upcoming Visit</div>
                </div>
            </div>

            <div class="content-grid">
                <div class="left-col">
                    <div class="card">
                        <div class="card-header">
                            <h3>Visit Request History</h3>
                            <a href="#" style="font-size:12px; color:var(--blue-acc); text-decoration:none; font-weight:500">View All</a>
                        </div>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Request Date</th>
                                    <th>Preferred Date</th>
                                    <th>Status</th>
                                    <th>Remarks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (recentVisits != null) { 
                                    for(FamilyDashboardService.VisitRequest v : recentVisits) { %>
                                    <tr>
                                        <td><%= v.getRequestDate() %></td>
                                        <td><%= v.getPreferredDate() %></td>
                                        <td>
                                            <span class="badge badge-<%= v.getStatus().toLowerCase() %>">
                                                <%= v.getStatus() %>
                                            </span>
                                        </td>
                                        <td style="color:var(--text-light); font-size:12px">
                                            <%= v.getStatus().equals("APPROVED") ? "Verified. Bring original ID." : "-" %>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="right-col">
                    
                    <div class="card">
                        <div class="card-header"><h3>Latest Updates</h3></div>
                        <div class="card-body">
                            <% if (notifications != null) { 
                                for(FamilyDashboardService.Notification n : notifications) { %>
                                <div class="notif-item">
                                    <div class="notif-dot" style="background:<%= n.getIsRead() ? "var(--border)" : "var(--blue-acc)" %>"></div>
                                    <div class="notif-content">
                                        <p><%= n.getMessage() %></p>
                                        <span><%= n.getTimeAgo() %></span>
                                    </div>
                                </div>
                            <% } } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    function updateClock() {
        const now = new Date();
        const options = { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
        document.getElementById('liveClock').textContent = now.toLocaleDateString('en-US', options);
    }
    setInterval(updateClock, 1000);
    updateClock();
</script>

</body>
</html>