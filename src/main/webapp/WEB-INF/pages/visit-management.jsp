<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.VisitRequest" %>
<%@ page import="com.anjal.model.User" %>

<%
String contextPath = request.getContextPath();
User user = (User) session.getAttribute("loggedInUser");
String adminName = (user != null) ? user.getFullName() : "Administrator";
List<VisitRequest> pendingRequests = (List<VisitRequest>) request.getAttribute("pendingRequests");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Visit Management | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
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
            --radius:12px;--radius-sm:8px;--transition:.2s ease
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}
        /* ── Sidebar ── */
        .sidebar{
            width:260px;min-height:100vh;background:var(--navy);
            display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;
            z-index:100;transition:transform .2s ease
        }
        .sidebar-logo{padding:20px 24px 16px;border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo-inner{display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:rgba(255,255,255,.12);border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .logo-icon svg{width:18px;height:18px;fill:none;stroke:#fff;stroke-width:1.8}
        .logo-text h2{font-family:'Playfair Display',Georgia,serif;font-size:14px;font-weight:600;color:#fff;line-height:1.2}
        .logo-text p{font-size:10px;color:rgba(255,255,255,.45);letter-spacing:.08em;text-transform:uppercase}
        .sidebar-nav{flex:1;padding:16px 0;overflow-y:auto}
        .nav-section-label{padding:8px 24px 4px;font-size:10px;color:rgba(255,255,255,.30);letter-spacing:.12em;text-transform:uppercase;font-weight:500}
        .nav-item{display:flex;align-items:center;gap:12px;padding:10px 24px;color:rgba(255,255,255,.65);text-decoration:none;font-size:13px;font-weight:400;border-left:3px solid transparent;transition:all .2s ease;cursor:pointer}
        .nav-item:hover{color:#fff;background:rgba(255,255,255,.06);border-left-color:rgba(255,255,255,.2)}
        .nav-item.active{color:#fff;background:rgba(58,111,216,.25);border-left-color:var(--blue-light);font-weight:500}
        .nav-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.7;flex-shrink:0}
        .nav-badge{margin-left:auto;background:rgba(217,79,79,.85);color:#fff;font-size:10px;font-weight:600;padding:2px 7px;border-radius:20px}
        .sidebar-footer{padding:16px 24px;border-top:1px solid rgba(255,255,255,.08)}
        .user-info{display:flex;align-items:center;gap:10px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,var(--blue-acc),var(--blue-light));border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:#fff;flex-shrink:0}
        .user-details p{font-size:12.5px;color:#fff;font-weight:500;line-height:1.2}
        .user-details span{font-size:10.5px;color:rgba(255,255,255,.45)}
        .logout-btn{margin-left:auto;background:none;border:none;cursor:pointer;color:rgba(255,255,255,.4);padding:4px;transition:color .2s ease;display:flex}
        .logout-btn:hover{color:rgba(255,255,255,.8)}
        .logout-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:2}
        
        .main-wrapper{margin-left:260px;flex:1;padding:28px}
        
        .card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);box-shadow:0 2px 8px rgba(26,39,68,.07);overflow:hidden;margin-bottom:24px}
        .card-header{padding:18px 20px;border-bottom:1px solid var(--border-light);display:flex;justify-content:space-between;align-items:center}
        
        .data-table{width:100%;border-collapse:collapse}
        .data-table th{padding:12px 16px;text-align:left;font-size:11px;text-transform:uppercase;background:var(--cloud);color:var(--text-light)}
        .data-table td{padding:14px 16px;font-size:13px;border-bottom:1px solid var(--border-light)}
        
        .btn{padding:8px 14px;border-radius:var(--radius-sm);font-size:12px;cursor:pointer;border:none;font-family:inherit;font-weight:500;text-decoration:none;display:inline-flex;align-items:center;gap:6px}
        .btn-approve{background:var(--success);color:white}
        .btn-reject{background:var(--error);color:white}
        
        /* Modal for responding */
        .modal{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center}
        .modal-content{background:white;padding:28px;border-radius:var(--radius);width:500px;max-width:90%;box-shadow:0 10px 25px rgba(0,0,0,0.2)}
        .form-group{margin-bottom:16px}
        .form-group label{display:block;font-size:13px;margin-bottom:6px;font-weight:500}
        .form-group input, .form-group select, .form-group textarea{width:100%;padding:10px;border:1px solid var(--border);border-radius:var(--radius-sm);font-family:inherit}
        
        .badge-pending{background:var(--warn-bg);color:var(--warn);padding:3px 8px;border-radius:20px;font-size:11px}
    </style>
</head>
<body>

<div class="layout">
    <!-- ══ SIDEBAR ══ -->
    <nav class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <div class="logo-text">
                    <h2>PMS Nepal</h2>
                    <p>Admin Portal</p>
                </div>
            </div>
        </div>

        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/admin-dashboard" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Dashboard
            </a>

            <p class="nav-section-label" style="margin-top:8px">Management</p>
            <a href="<%= contextPath %>/prisoner-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                Prisoners
            </a>
            <a href="staff-management.jsp" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                Staff
            </a>
            <a href="<%= contextPath %>/family-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                Family Members
            </a>

            <p class="nav-section-label" style="margin-top:8px">Operations</p>
            <a href="<%= contextPath %>/admin/visit-management" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Visit Requests
            </a>
            <a href="<%= contextPath %>/trash" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                Trash / Restore
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= adminName.substring(0,1).toUpperCase() %></div>
                <div class="user-details">
                    <p><%= adminName %></p>
                    <span>Administrator</span>
                </div>
                <a href="<%= contextPath %>/logout" class="logout-btn" title="Logout">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                </a>
            </div>
        </div>
    </nav>

    <div class="main-wrapper">
        <div class="card">
            <div class="card-header">
                <h3>Pending Visit Requests</h3>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Visitor</th>
                        <th>Prisoner</th>
                        <th>Preferred Date</th>
                        <th>Relation</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(pendingRequests == null || pendingRequests.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--text-light)">No pending requests found</td></tr>
                    <% } else { 
                        for(VisitRequest vr : pendingRequests) { %>
                        <tr>
                            <td><%= vr.getFamilyMember().getUser().getFullName() %></td>
                            <td><%= vr.getPrisoner().getFullName() %> (<%= vr.getPrisoner().getPrisonerId() %>)</td>
                            <td><%= vr.getPreferredVisitDate() %></td>
                            <td><%= vr.getRelation() %></td>
                            <td><span class="badge-pending">Pending</span></td>
                            <td>
                                <button class="btn btn-approve" onclick="openRespondModal('<%= vr.getId() %>', 'APPROVED', '<%= vr.getPreferredVisitDate() %>')">Approve</button>
                                <button class="btn btn-reject" onclick="openRespondModal('<%= vr.getId() %>', 'REJECTED')">Reject</button>
                            </td>
                        </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Response Modal -->
<div id="respondModal" class="modal">
    <div class="modal-content">
        <h2 id="modalTitle" style="margin-bottom:20px">Respond to Request</h2>
        <form action="<%= contextPath %>/admin/visit-respond" method="POST">
            <input type="hidden" name="requestId" id="modalRequestId">
            <input type="hidden" name="status" id="modalStatus">

            <div id="approveFields">
                <div class="form-group">
                    <label>Scheduled Date</label>
                    <input type="date" name="scheduledDate" id="modalDate">
                </div>
                <div class="form-group">
                    <label>Scheduled Time</label>
                    <input type="time" name="scheduledTime" value="10:00">
                </div>
                <div class="form-group">
                    <label>Meeting Room</label>
                    <input type="text" name="room" placeholder="e.g. Visiting Room A">
                </div>
            </div>

            <div class="form-group">
                <label>Admin Notes / Reason</label>
                <textarea name="notes" placeholder="Additional details or reason for rejection..."></textarea>
            </div>

            <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:20px">
                <button type="button" class="btn" style="background:var(--mist)" onclick="closeModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" id="submitBtn" style="background:var(--blue-acc);color:white">Confirm Response</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openRespondModal(id, status, preferredDate) {
        document.getElementById('modalRequestId').value = id;
        document.getElementById('modalStatus').value = status;
        document.getElementById('modalTitle').textContent = status === 'APPROVED' ? 'Approve Visit' : 'Reject Visit Request';
        
        const approveFields = document.getElementById('approveFields');
        const submitBtn = document.getElementById('submitBtn');
        
        if(status === 'APPROVED') {
            approveFields.style.display = 'block';
            submitBtn.style.background = '#1e7d5a';
            if(preferredDate) document.getElementById('modalDate').value = preferredDate;
        } else {
            approveFields.style.display = 'none';
            submitBtn.style.background = '#c94040';
        }
        
        document.getElementById('respondModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('respondModal').style.display = 'none';
    }

    window.onclick = function(event) {
        if (event.target == document.getElementById('respondModal')) {
            closeModal();
        }
    }
</script>

</body>
</html>
