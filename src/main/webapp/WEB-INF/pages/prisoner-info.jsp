<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.anjal.model.Prisoner" %>
<% 
    Prisoner p = (Prisoner) request.getAttribute("p");
    String contextPath = request.getContextPath();
    // Hardcoded for UI consistency
    String familyName = "Sita Thapa";
    String initials = "ST";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prisoner Details | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        /* REUSING DASHBOARD CORE STYLES */
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744; --navy-mid:#243358; --blue-acc:#3a6fd8; 
            --blue-light:#4f85ec; --white:#ffffff; --cloud:#f4f6fb;
            --border:#d0d9ee; --border-light:#e8edf7;
            --text-main:#1a2744; --text-sub:#5a7099; --text-light:#8e9ec1;
            --sidebar-w:260px; --header-h:64px; --radius:12px;
        }
        body{font-family:'DM Sans',sans-serif; color:var(--text-main); background:var(--cloud); min-height:100vh}
        .layout{display:flex; min-height:100vh}

        /* Sidebar Style */
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
            color:rgba(255,255,255,0.7); text-decoration:none; font-size:14px;
        }
        .nav-item:hover, .nav-item.active{color:#fff; background:rgba(255,255,255,0.05)}
        .nav-item.active{border-left:4px solid var(--blue-light); background:rgba(58,111,216,0.1)}

        /* Main Content */
        .main-wrapper{margin-left:var(--sidebar-w); flex:1; display:flex; flex-direction:column}
        .topbar{
            height:var(--header-h); background:var(--white); padding:0 30px;
            display:flex; align-items:center; border-bottom:1px solid var(--border-light);
        }
        .page-content{padding:30px; max-width: 1000px;}

        /* Info Card Specifics */
        .info-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border-light); overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
        .info-header { background: linear-gradient(to right, var(--navy), var(--navy-mid)); color: white; padding: 40px; display: flex; align-items: center; gap: 25px; }
        .info-avatar { width: 80px; height: 80px; background: rgba(255,255,255,0.1); border-radius: 20px; display: flex; align-items: center; justify-content: center; font-size: 32px; font-weight: 600; }
        
        .info-body { padding: 40px; }
        .details-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 30px; }
        .detail-item label { display: block; font-size: 11px; text-transform: uppercase; color: var(--text-light); letter-spacing: 1px; margin-bottom: 6px; }
        .detail-item p { font-size: 15px; font-weight: 500; color: var(--navy); margin: 0; }
        
        .status-pill { background: #1e7d5a; color: white; padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        
        .divider { height: 1px; background: var(--border-light); margin: 30px 0; }
        .notice-box { background: var(--info-bg); padding: 20px; border-radius: 8px; border-left: 4px solid var(--blue-acc); font-size: 13px; line-height: 1.6; }
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
            <a href="<%= contextPath %>/family-dashboard" class="nav-item">Dashboard</a>
            <a href="<%= contextPath %>/family-prisoner-info" class="nav-item active">Prisoner Info</a>
            <a href="<%= contextPath %>/family-request-visit" class="nav-item">Request Visit</a>
            <a href="#" class="nav-item">Visit History</a>
            
            <p class="nav-section-label" style="margin-top:20px">Account</p>
            <a href="#" class="nav-item">Notifications</a>
            <a href="#" class="nav-item">Profile Settings</a>
            <a href="#" class="nav-item">Inquiry / Contact</a>
            <a href="<%= contextPath %>/logout" class="nav-item" style="color:#ff6b6b">Logout</a>
        </nav>
    </aside>

    <main class="main-wrapper">
        <header class="topbar">
            <div style="font-size: 14px; font-weight: 500; color: var(--text-sub);">
                Authorized Prisoner Details
            </div>
        </header>

        <div class="page-content">
            <div class="info-card">
                <div class="info-header">
                    <div class="info-avatar"><%= p.getFullName().substring(0,1) %></div>
                    <div>
                        <div style="display: flex; align-items: center; gap: 15px;">
                            <h1 style="margin: 0; font-size: 24px;"><%= p.getFullName() %></h1>
                            <span class="status-pill"><%= p.getStatus() %></span>
                        </div>
                        <p style="opacity: 0.7; font-size: 14px; margin-top: 5px;">Prisoner ID: <%= p.getPrisonerId() %></p>
                    </div>
                </div>

                <div class="info-body">
                    <div class="details-grid">
                        <div class="detail-item">
                            <label>Full Name</label>
                            <p><%= p.getFullName() %></p>
                        </div>
                        <div class="detail-item">
                            <label>Gender</label>
                            <p><%= p.getGender() %></p>
                        </div>
                        <div class="detail-item">
                            <label>Facility Location</label>
                            <p>Block <%= p.getBlockNumber() %> • Central Jail</p>
                        </div>
                        <div class="detail-item">
                            <label>Security Level</label>
                            <p><%= p.getSecurityLevel() %> Security</p>
                        </div>
                        <div class="detail-item">
                            <label>Date of Admission</label>
                            <p><%= p.getAdmissionDate() %></p>
                        </div>
                        <div class="detail-item">
                            <label>Expected Release Date</label>
                            <p><%= p.getReleaseDate() %></p>
                        </div>
                        <div class="detail-item">
                            <label>Sentence Years</label>
                            <p><%= p.getSentenceYears() %> Years</p>
                        </div>
                        <div class="detail-item">
                            <label>Emergency Contact</label>
                            <p><%= p.getEmergencyContact() %></p>
                        </div>
                    </div>

                    <div class="divider"></div>

                    <div class="notice-box">
                        <strong>Family Notice:</strong> The information displayed above is synchronized with official records. If there are discrepancies or if you need to update the emergency contact information, please visit the administration office with valid identification.
                    </div>

                    <div style="margin-top: 30px;">
                        <a href="<%= contextPath %>/family-request-visit" 
                           style="display: inline-block; background: var(--navy); color: white; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: 500;">
                            Request Visit for this Prisoner
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

</body>
</html>