<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String trashedJson = (String) request.getAttribute("trashedJson");
    if (trashedJson == null || trashedJson.trim().isEmpty()) {
        trashedJson = "[]";
    }
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trash / Restore | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />
    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round" style="width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:2"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div class="topbar-title">Trash / Restore</div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Trash Bin</h1>
                    <p>Restore or permanently delete removed records</p>
                </div>
            </div>

            <div class="table-card">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th class="photo-col">Photo</th>
                            <th>Prisoner ID</th>
                            <th>Name</th>
                            <th>Crime</th>
                            <th>Deleted At</th>
                            <th class="actions-col">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="trashTbody"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    let allTrashed = <%= trashedJson %>;
    function renderTable() {
        const tbody = document.getElementById('trashTbody');
        if (allTrashed.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Trash is empty</td></tr>';
        } else {
            tbody.innerHTML = allTrashed.map(p => `
                <tr>
                    <td>\${p.photoDataUri ? `<img class="prisoner-photo" src="\${p.photoDataUri}">` : `<div class="prisoner-photo" style="background:#eee"></div>`}</td>
                    <td><code>\${p.prisonerId}</code></td>
                    <td class="text-bold">\${p.fullName}</td>
                    <td>\${p.crimeType}</td>
                    <td>\${p.deletedAt}</td>
                    <td>
                        <button class="btn btn-primary btn-sm" onclick="restore('\${p.prisonerId}')">Restore</button>
                    </td>
                </tr>
            `).join('');
        }
    }
    function restore(id) {
        fetch('<%= contextPath %>/trash', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=restore&prisonerId=' + id
        }).then(() => window.location.reload());
    }
    renderTable();
</script>
</body>
</html>
