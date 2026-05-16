<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.anjal.model.VisitRequest" %>
<%@ page import="com.anjal.model.User" %>

<%
String contextPath = request.getContextPath();
List<VisitRequest> pendingRequests = (List<VisitRequest>) request.getAttribute("pendingRequests");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Visit Management | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
</head>
<body>

<div class="layout">
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />

    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div class="topbar-title">Visit Management</div>
        </div>

        <div class="page-content">
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
                            <tr><td colspan="6" class="empty-state">No pending requests found</td></tr>
                        <% } else { 
                            for(VisitRequest vr : pendingRequests) { %>
                            <tr>
                                <td class="text-bold"><%= vr.getFamilyMember().getUser().getFullName() %></td>
                                <td><%= vr.getPrisoner().getFullName() %> (<%= vr.getPrisoner().getPrisonerId() %>)</td>
                                <td><%= vr.getPreferredVisitDate() %></td>
                                <td><%= vr.getRelation() %></td>
                                <td><span class="badge badge-pending">Pending</span></td>
                                <td>
                                    <button class="btn btn-approve btn-sm" onclick="openRespondModal('<%= vr.getId() %>', 'APPROVED', '<%= vr.getPreferredVisitDate() %>')">Approve</button>
                                    <button class="btn btn-reject btn-sm" onclick="openRespondModal('<%= vr.getId() %>', 'REJECTED')">Reject</button>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Response Modal -->
<div id="respondModal" class="modal-overlay">
    <div class="modal modal-md">
        <div class="modal-header">
            <h2 id="modalTitle">Respond to Request</h2>
            <button class="modal-close" onclick="closeModal()"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>
        </div>
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

            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" id="submitBtn">Confirm Response</button>
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
            submitBtn.classList.remove('btn-danger'); // Ensure correct button style
            submitBtn.classList.add('btn-approve');
            if(preferredDate) document.getElementById('modalDate').value = preferredDate;
        } else {
            approveFields.style.display = 'none';
            submitBtn.classList.remove('btn-approve'); // Ensure correct button style
            submitBtn.classList.add('btn-danger');
        }
        
        document.getElementById('respondModal').classList.add('show');
    }

    function closeModal() {
        document.getElementById('respondModal').classList.remove('show');
    }

    window.onclick = function(event) {
        if (event.target == document.getElementById('respondModal')) {
            closeModal();
        }
    }
</script>

</body>
</html>
