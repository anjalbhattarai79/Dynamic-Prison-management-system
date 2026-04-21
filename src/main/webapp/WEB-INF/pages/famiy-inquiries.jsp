<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inquiries | Family Portal</title>
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
            <a href="<%= contextPath %>/family-inquiries" class="nav-item active"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>Inquiries</a>
            <a href="<%= contextPath %>/family-profile" class="nav-item"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>My Profile</a>
        </div>
        <div class="sidebar-footer"><div class="user-info"><div class="user-avatar">F</div><div class="user-details"><p>Family Member</p><span>Family Member</span></div><a href="<%= contextPath %>/logout" class="logout-btn" title="Logout"><svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></a></div></div>
    </nav>

    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()"><svg viewBox="0 0 24 24"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg></button>
            <div><div class="topbar-title">Support Inquiries</div><div class="topbar-sub">Send and track your questions</div></div>
        </div>

        <div class="page-content">
            <div class="grid-2">
                <div class="card">
                    <div class="card-header"><h3>New Inquiry</h3></div>
                    <div class="card-body">
                        <form onsubmit="previewInquiry(event)">
                            <div class="form-grid">
                                <div class="field span-2">
                                    <label for="subject">Subject</label>
                                    <input id="subject" placeholder="Example: Request for health update" required>
                                </div>
                                <div class="field span-2">
                                    <label for="message">Message</label>
                                    <textarea id="message" placeholder="Write your inquiry..." required></textarea>
                                </div>
                            </div>
                            <div class="inline-actions"><button type="submit" class="btn btn-primary">Send Inquiry</button></div>
                        </form>
                        <div id="inquiryPreview" class="notice" style="margin-top:12px;display:none"></div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header"><h3>Previous Inquiries</h3></div>
                    <div class="card-body">
                        <div class="list">
                            <div class="list-item"><div><div class="list-item-title">Health status update</div><div class="list-item-sub">Reply received 2 days ago</div></div><div class="list-item-right"><span class="badge badge-ready">Answered</span></div></div>
                            <div class="list-item"><div><div class="list-item-title">Reschedule visit VR-304</div><div class="list-item-sub">Waiting for admin response</div></div><div class="list-item-right"><span class="badge badge-pending">Open</span></div></div>
                            <div class="list-item"><div><div class="list-item-title">Document verification help</div><div class="list-item-sub">Closed last week</div></div><div class="list-item-right"><span class="badge badge-approved">Closed</span></div></div>
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
function previewInquiry(event){
    event.preventDefault();
    const s = document.getElementById('subject').value;
    const m = document.getElementById('message').value;
    const p = document.getElementById('inquiryPreview');
    p.style.display = 'block';
    p.textContent = 'Preview only: inquiry queued with subject "' + s + '" and message length ' + m.length + ' characters.';
}
</script>
</body>
</html>
