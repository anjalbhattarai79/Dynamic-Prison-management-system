<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.Prisoner" %>
<%@ page import="com.anjal.model.User" %>

<%
String contextPath = request.getContextPath();
User user = (User) session.getAttribute("loggedInUser");
String familyName = (user != null) ? user.getFullName() : "Family Member";

List<Prisoner> linkedPrisoners = (List<Prisoner>) request.getAttribute("linkedPrisoners");
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
            --error:#c94040;--error-bg:#fef2f2;
            --radius:12px;--radius-sm:8px;--transition:.2s ease
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}
        
        .sidebar{
            width:260px;min-height:100vh;background:var(--navy);
            display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;
            z-index:100;
        }
        .sidebar-logo{padding:20px 24px 16px;border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo-inner{display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:rgba(255,255,255,.12);border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .logo-icon svg{width:18px;height:18px;fill:none;stroke:#fff;stroke-width:1.8}
        .logo-text h2{font-family:'Playfair Display',Georgia,serif;font-size:14px;font-weight:600;color:#fff;line-height:1.2}
        .logo-text p{font-size:10px;color:rgba(255,255,255,.45);letter-spacing:.08em;text-transform:uppercase}
        
        .sidebar-nav{flex:1;padding:16px 0}
        .nav-item{display:flex;align-items:center;gap:12px;padding:10px 24px;color:rgba(255,255,255,.65);text-decoration:none;font-size:13px}
        .nav-item:hover{color:#fff;background:rgba(255,255,255,.06)}
        .nav-item.active{color:#fff;background:rgba(58,111,216,.25);border-left:3px solid var(--blue-light)}
        .nav-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.7}

        .main-wrapper{margin-left:260px;flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{height:64px;background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px}
        .topbar-title{font-size:16px;font-weight:600}

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
            <a href="<%= contextPath %>/family-dashboard" class="nav-item"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg> Dashboard</a>
            <a href="#" class="nav-item active"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg> My Visits</a>
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
                        <label for="prisonerId">Select Prisoner</label>
                        <select name="prisonerId" id="prisonerId" required>
                            <option value="">-- Choose Prisoner --</option>
                            <% if(linkedPrisoners != null) { 
                                for(Prisoner p : linkedPrisoners) { %>
                                <option value="<%= p.getId() %>"><%= p.getFullName() %> (<%= p.getPrisonerId() %>)</option>
                            <% } } %>
                        </select>
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
