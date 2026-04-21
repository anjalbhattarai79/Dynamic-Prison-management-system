<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Family Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= contextPath %>/css/family-portal.css">
</head>
<body>
<div class="sidebar-overlay" id="overlay" onclick="closeSidebar()"></div>
<div class="layout">
    <nav class="sidebar" id="sidebar">
        <div class="sidebar-logo"><div class="sidebar-logo-inner"><div class="logo-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div><div class="logo-text"><h2>PMS Nepal</h2><p>Family Portal</p></div></div></div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/family-dashboard" class="nav-item"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>Dashboard</a>
            <p class="nav-section-label" style="margin-top:8px">Visits</p>
            <a href="<%= contextPath %>/family-request-visit" class="nav-item"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>Request Visit</a>
            <a href="<%= contextPath %>/family-visits" class="nav-item"><svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>Visit History</a>
            <p class="nav-section-label" style="margin-top:8px">Support</p>
            <a href="<%= contextPath %>/family-inquiries" class="nav-item"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>Inquiries</a>
            <a href="<%= contextPath %>/family-profile" class="nav-item active"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>My Profile</a>
        </div>
        <div class="sidebar-footer"><div class="user-info"><div class="user-avatar">F</div><div class="user-details"><p>Family Member</p><span>Family Member</span></div><a href="<%= contextPath %>/logout" class="logout-btn" title="Logout"><svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></a></div></div>
    </nav>

    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()"><svg viewBox="0 0 24 24"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg></button>
            <div><div class="topbar-title">My Profile</div><div class="topbar-sub">Manage contact details and preferences</div></div>
        </div>

        <div class="page-content">
            <div class="grid-2">
                <div class="card">
                    <div class="card-header"><h3>Personal Information</h3></div>
                    <div class="card-body">
                        <form onsubmit="saveProfile(event)">
                            <div class="form-grid">
                                <div class="field"><label for="fullName">Full Name</label><input id="fullName" value="Sarita Karki" required></div>
                                <div class="field"><label for="phone">Phone</label><input id="phone" value="+977-98XXXXXXXX" required></div>
                                <div class="field"><label for="email">Email</label><input id="email" type="email" value="family@example.com" required></div>
                                <div class="field"><label for="relation">Primary Relation</label><select id="relation"><option>Mother</option><option>Father</option><option>Spouse</option><option>Sibling</option></select></div>
                                <div class="field span-2"><label for="address">Address</label><textarea id="address">Kathmandu, Nepal</textarea></div>
                            </div>
                            <div class="inline-actions"><button class="btn btn-primary" type="submit">Save Changes</button></div>
                        </form>
                        <div id="profileNotice" class="notice" style="margin-top:12px;display:none"></div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header"><h3>Linked Account Summary</h3></div>
                    <div class="card-body">
                        <div class="list">
                            <div class="list-item"><div><div class="list-item-title">Linked Prisoners</div><div class="list-item-sub">2 linked profiles</div></div><div class="list-item-right"><span class="badge badge-ready">Verified</span></div></div>
                            <div class="list-item"><div><div class="list-item-title">Login Method</div><div class="list-item-sub">Temporary code onboarding completed</div></div><div class="list-item-right"><span class="badge badge-approved">Enabled</span></div></div>
                            <div class="list-item"><div><div class="list-item-title">Security Reminder</div><div class="list-item-sub">Change password every 60 days once backend is enabled</div></div><div class="list-item-right"><span class="badge badge-pending">Advisory</span></div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function openSidebar(){document.getElementById('sidebar').classList.add('open');document.getElementById('overlay').classList.add('show');}
function closeSidebar(){document.getElementById('sidebar').classList.remove('open');document.getElementById('overlay').classList.remove('show');}
function saveProfile(event){
    event.preventDefault();
    const n = document.getElementById('profileNotice');
    n.style.display = 'block';
    n.textContent = 'Frontend preview: profile updates are not persisted yet.';
}
</script>
</body>
</html>
