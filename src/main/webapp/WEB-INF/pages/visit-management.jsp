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
        .sidebar{width:260px;background:var(--navy);color:white;position:fixed;height:100vh}
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
    <!-- Mini sidebar mock -->
    <div class="sidebar" style="padding:20px">
        <h2 style="font-family:'Playfair Display';font-size:18px;margin-bottom:30px">PMS Nepal</h2>
        <a href="<%= contextPath %>/admin-dashboard" style="color:white;text-decoration:none;font-size:14px;display:block;margin-bottom:15px">Dashboard</a>
        <a href="<%= contextPath %>/admin/visit-management" style="color:white;text-decoration:none;font-size:14px;display:block;margin-bottom:15px;font-weight:bold">Visit Requests</a>
    </div>

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
