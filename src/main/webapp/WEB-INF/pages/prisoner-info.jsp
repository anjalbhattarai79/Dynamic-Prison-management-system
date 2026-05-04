<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.Prisoner" %>
<%
    String contextPath = request.getContextPath();
    Prisoner p = (Prisoner) request.getAttribute("selectedPrisoner");
    List<Prisoner> linkedPrisoners = (List<Prisoner>) request.getAttribute("linkedPrisoners");

    String familyName = (String) request.getAttribute("familyName");
    if (familyName == null || familyName.isBlank()) {
        familyName = "Family Member";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prisoner Details | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= contextPath %>/css/family-portal.css">
    <style>
        .hero-card {
            background: linear-gradient(145deg, #16243f, #20355f);
            color: #fff;
            border-radius: var(--radius);
            padding: 26px;
            margin-bottom: 18px;
            border: 1px solid rgba(255,255,255,.12);
            box-shadow: var(--shadow-md);
        }
        .hero-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .hero-sub {
            font-size: 13px;
            opacity: .78;
        }
        .switcher {
            margin-top: 14px;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .switcher a {
            text-decoration: none;
            color: #dbe7ff;
            border: 1px solid rgba(255,255,255,.25);
            padding: 7px 11px;
            border-radius: 999px;
            font-size: 12px;
            transition: var(--transition);
            background: rgba(255,255,255,.06);
        }
        .switcher a.active {
            background: #eaf1ff;
            color: #163063;
            border-color: #eaf1ff;
            font-weight: 600;
        }
        .details-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }
        .detail {
            border: 1px solid var(--border-light);
            border-radius: 10px;
            padding: 12px;
            background: #fbfcff;
        }
        .detail .label {
            font-size: 11px;
            color: var(--text-light);
            text-transform: uppercase;
            letter-spacing: .08em;
            margin-bottom: 5px;
        }
        .detail .value {
            font-size: 14px;
            color: var(--text-main);
            font-weight: 500;
        }
        .empty-state {
            text-align: center;
            padding: 36px 16px;
            color: var(--text-sub);
        }
        @media (max-width: 760px) {
            .details-grid {
                grid-template-columns: 1fr;
            }
            .hero-title {
                font-size: 20px;
            }
        }
    </style>
</head>
<body>
<div class="sidebar-overlay" id="overlay" onclick="closeSidebar()"></div>
<div class="layout">
    <nav class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <div class="logo-text"><h2>PMS Nepal</h2><p>Family Portal</p></div>
            </div>
        </div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/family-dashboard<%= p != null ? "?prisonerId=" + p.getPrisonerId() : "" %>" class="nav-item"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>Dashboard</a>
            <a href="<%= contextPath %>/family-prisoner-info<%= p != null ? "?prisonerId=" + p.getPrisonerId() : "" %>" class="nav-item active"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>Prisoner Info</a>

            <p class="nav-section-label" style="margin-top:8px">Visits</p>
            <a href="<%= contextPath %>/family-request-visit" class="nav-item"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>Request Visit</a>
            <a href="<%= contextPath %>/family-visits" class="nav-item"><svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>Visit History</a>

            <p class="nav-section-label" style="margin-top:8px">Support</p>
            <a href="<%= contextPath %>/family-inquiries" class="nav-item"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>Inquiries</a>
            <a href="<%= contextPath %>/family-profile" class="nav-item"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>My Profile</a>
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= familyName.substring(0, 1).toUpperCase() %></div>
                <div class="user-details"><p><%= familyName %></p><span>Family Member</span></div>
                <a href="<%= contextPath %>/logout" class="logout-btn" title="Logout"><svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></a>
            </div>
        </div>
    </nav>

    <main class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()"><svg viewBox="0 0 24 24"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg></button>
            <div>
                <div class="topbar-title">Authorized Prisoner Details</div>
                <div class="topbar-sub"><%= p != null ? p.getPrisonerId() : "No authorized prisoner" %></div>
            </div>
            <div class="topbar-right">
                <a href="<%= contextPath %>/family-request-visit" class="btn btn-primary">Request Visit</a>
            </div>
        </div>

        <div class="page-content">
            <% if (p != null) { %>
            <div class="hero-card">
                <div class="hero-title"><%= p.getFullName() %></div>
                <div class="hero-sub">Prisoner ID: <%= p.getPrisonerId() %> | Block <%= p.getBlockNumber() %> | <%= p.getSecurityLevel() %> Security</div>

                <% if (linkedPrisoners != null && !linkedPrisoners.isEmpty()) { %>
                <div class="switcher">
                    <% for (Prisoner linked : linkedPrisoners) {
                           boolean active = p.getPrisonerId() != null && p.getPrisonerId().equals(linked.getPrisonerId()); %>
                        <a href="<%= contextPath %>/family-prisoner-info?prisonerId=<%= linked.getPrisonerId() %>" class="<%= active ? "active" : "" %>"><%= linked.getPrisonerId() %> - <%= linked.getFullName() %></a>
                    <% } %>
                </div>
                <% } %>
            </div>

            <div class="card">
                <div class="card-header"><h3>Profile Summary</h3></div>
                <div class="card-body">
                    <div class="details-grid">
                        <div class="detail"><div class="label">Full Name</div><div class="value"><%= p.getFullName() != null ? p.getFullName() : "-" %></div></div>
                        <div class="detail"><div class="label">Gender</div><div class="value"><%= p.getGender() != null ? p.getGender() : "-" %></div></div>
                        <div class="detail"><div class="label">Date of Birth</div><div class="value"><%= p.getDateOfBirth() != null ? p.getDateOfBirth() : "-" %></div></div>
                        <div class="detail"><div class="label">Admission Date</div><div class="value"><%= p.getAdmissionDate() != null ? p.getAdmissionDate() : "-" %></div></div>
                        <div class="detail"><div class="label">Expected Release</div><div class="value"><%= p.getReleaseDate() != null ? p.getReleaseDate() : "-" %></div></div>
                        <div class="detail"><div class="label">Security Level</div><div class="value"><%= p.getSecurityLevel() != null ? p.getSecurityLevel() : "-" %></div></div>
                        <div class="detail"><div class="label">Status</div><div class="value"><%= p.getStatus() != null ? p.getStatus() : "-" %></div></div>
                        <div class="detail"><div class="label">Emergency Contact</div><div class="value"><%= p.getEmergencyContact() != null ? p.getEmergencyContact() : "-" %></div></div>
                    </div>

                    <div class="notice" style="margin-top:16px;">
                        This information is synced from official prison records. Contact administration for record corrections.
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="card">
                <div class="empty-state">
                    No authorized prisoner record was found for your account.
                </div>
            </div>
            <% } %>
        </div>
    </main>
</div>

<script>
function openSidebar(){
    document.getElementById('sidebar').classList.add('open');
    document.getElementById('overlay').classList.add('show');
}
function closeSidebar(){
    document.getElementById('sidebar').classList.remove('open');
    document.getElementById('overlay').classList.remove('show');
}
</script>
</body>
</html>
