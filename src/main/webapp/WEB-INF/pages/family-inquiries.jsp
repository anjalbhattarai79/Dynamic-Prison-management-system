<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% String path = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Inquiry & Support | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        /* REUSING CORE LAYOUT STYLES */
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744; --navy-mid:#243358; --blue-acc:#3a6fd8; 
            --white:#ffffff; --cloud:#f4f6fb; --border-light:#e8edf7;
            --text-main:#1a2744; --text-sub:#5a7099;
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
        .nav-item{
            display:flex; align-items:center; gap:12px; padding:12px 24px;
            color:rgba(255,255,255,0.7); text-decoration:none; font-size:14px;
        }
        .nav-item:hover, .nav-item.active{color:#fff; background:rgba(255,255,255,0.05)}
        .nav-item.active{border-left:4px solid var(--blue-acc); background:rgba(58,111,216,0.1)}

        .main-wrapper{margin-left:var(--sidebar-w); flex:1; display:flex; flex-direction:column}
        .topbar{height:var(--header-h); background:var(--white); padding:0 30px; display:flex; align-items:center; border-bottom:1px solid var(--border-light);}

        /* Content Area */
        .page-content{padding:40px; display:grid; grid-template-columns: 1fr 350px; gap:30px;}
        .card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border-light); box-shadow: 0 4px 12px rgba(0,0,0,0.03); overflow: hidden; }
        .card-header { padding: 25px; border-bottom: 1px solid var(--border-light); }
        .card-header h2 { font-size: 18px; margin: 0; }
        
        .form-body { padding: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px; color: var(--navy); }
        
        input, select, textarea {
            width: 100%; padding: 12px; border: 1.5px solid var(--border-light); 
            border-radius: 8px; font-family: inherit; font-size: 14px;
        }
        
        .btn-submit {
            background: var(--blue-acc); color: white; border: none; padding: 14px;
            border-radius: 8px; font-weight: 600; width: 100%; cursor: pointer; transition: 0.2s;
        }
        .btn-submit:hover { background: var(--navy); }

        .contact-info { padding: 25px; }
        .info-item { margin-bottom: 20px; }
        .info-item h4 { font-size: 12px; text-transform: uppercase; color: var(--text-sub); margin-bottom: 5px; }
        .info-item p { font-size: 14px; font-weight: 500; }
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
            <a href="<%= path %>/family-dashboard" class="nav-item">Dashboard</a>
            <a href="<%= path %>/family-prisoner-info" class="nav-item">Prisoner Info</a>
            <a href="<%= path %>/family-request-visit" class="nav-item">Request Visit</a>
            <a href="<%= path %>/family-inquiry" class="nav-item active">Inquiry / Contact</a>
            <a href="#" class="nav-item">Profile</a>
            <a href="#" class="nav-item" style="margin-top:20px; color:#ff6b6b">Logout</a>
        </nav>
    </aside>

    <main class="main-wrapper">
        <header class="topbar">
            <div style="font-size: 14px; font-weight: 500; color: var(--text-sub);">Support & Communication</div>
        </header>

        <div class="page-content">
            <div class="card">
                <div class="card-header">
                    <h2>Send Inquiry</h2>
                </div>
                <div class="form-body">
                    <form action="<%= path %>/family-inquiry" method="POST">
                        <div class="form-group">
                            <label for="subject">Subject</label>
                            <select id="subject" name="subject" required>
                                <option value="Visit Query">Visit Related Query</option>
                                <option value="Medical Info">Prisoner Health Update</option>
                                <option value="Money/Supplies">Delivering Supplies</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="message">Message</label>
                            <textarea id="message" name="message" rows="6" placeholder="Describe your inquiry in detail..." required></textarea>
                        </div>

                        <button type="submit" class="btn-submit">Send Message</button>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2>Office Contact</h2>
                </div>
                <div class="contact-info">
                    <div class="info-item">
                        <h4>Office Hours</h4>
                        <p><%= request.getAttribute("officeHours") %></p>
                    </div>
                    <div class="info-item">
                        <h4>Admin Email</h4>
                        <p><%= request.getAttribute("supportEmail") %></p>
                    </div>
                    <div class="info-item">
                        <h4>Hotline</h4>
                        <p>+977-01-4XXXXXX</p>
                    </div>
                    <div class="info-item">
                        <h4>Address</h4>
                        <p>Central Jail Lane, Kalimati,<br>Kathmandu, Nepal</p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

</body>
</html>