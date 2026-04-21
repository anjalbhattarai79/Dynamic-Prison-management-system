<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    if (session.getAttribute("userId") == null ||
        (!("ADMIN".equals(session.getAttribute("role"))) && !("STAFF".equals(session.getAttribute("role"))))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String role = (String) session.getAttribute("role");
    String userName = (String) session.getAttribute("fullName");
    if (userName == null) userName = "User";
    String contextPath = request.getContextPath();

    String trashedJson = (String) request.getAttribute("trashedJson");
    if (trashedJson == null || trashedJson.trim().isEmpty()) {
        trashedJson = "[]";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trash / Restore | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --navy:#1a2744;--blue-acc:#3a6fd8;--blue-light:#4f85ec;--cloud:#f4f6fb;--white:#ffffff;
            --border:#d0d9ee;--border-light:#e8edf7;--text-main:#1a2744;--text-sub:#5a7099;--text-light:#8e9ec1;
            --error:#c94040;--error-bg:#fef2f2;--error-border:#f5c0c0;--success:#1e7d5a;--success-bg:#edf7f3;
            --sidebar-w:260px;--header-h:64px;--radius:12px;--radius-sm:8px;--transition:.2s ease;
            --shadow-sm:0 2px 8px rgba(26,39,68,.07)
        }
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        .layout{display:flex;min-height:100vh}
        .sidebar{width:var(--sidebar-w);min-height:100vh;background:var(--navy);display:flex;flex-direction:column;position:fixed;left:0;top:0;bottom:0;z-index:100}
        .sidebar-logo{padding:20px 24px 16px;border-bottom:1px solid rgba(255,255,255,.08)}
        .sidebar-logo-inner{display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:rgba(255,255,255,.12);border-radius:10px;display:flex;align-items:center;justify-content:center}
        .logo-icon svg{width:18px;height:18px;fill:none;stroke:#fff;stroke-width:1.8}
        .logo-text h2{font-family:'Playfair Display',Georgia,serif;font-size:14px;font-weight:600;color:#fff}
        .logo-text p{font-size:10px;color:rgba(255,255,255,.45);letter-spacing:.08em;text-transform:uppercase}
        .sidebar-nav{flex:1;padding:16px 0;overflow-y:auto}
        .nav-section-label{padding:8px 24px 4px;font-size:10px;color:rgba(255,255,255,.30);letter-spacing:.12em;text-transform:uppercase;font-weight:500}
        .nav-item{display:flex;align-items:center;gap:12px;padding:10px 24px;color:rgba(255,255,255,.65);text-decoration:none;font-size:13px;border-left:3px solid transparent;transition:all var(--transition)}
        .nav-item:hover{color:#fff;background:rgba(255,255,255,.06);border-left-color:rgba(255,255,255,.2)}
        .nav-item.active{color:#fff;background:rgba(58,111,216,.25);border-left-color:var(--blue-light);font-weight:500}
        .nav-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.7;flex-shrink:0}
        .sidebar-footer{padding:16px 24px;border-top:1px solid rgba(255,255,255,.08)}
        .user-info{display:flex;align-items:center;gap:10px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,var(--blue-acc),var(--blue-light));border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:#fff}
        .user-details p{font-size:12.5px;color:#fff;font-weight:500}
        .user-details span{font-size:10.5px;color:rgba(255,255,255,.45)}
        .logout-btn{margin-left:auto;background:none;border:none;cursor:pointer;color:rgba(255,255,255,.4);padding:4px;display:flex}
        .logout-btn:hover{color:rgba(255,255,255,.8)}
        .logout-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:2}
        .main-wrapper{margin-left:var(--sidebar-w);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{height:var(--header-h);background:var(--white);border-bottom:1px solid var(--border-light);display:flex;align-items:center;padding:0 28px;gap:16px;position:sticky;top:0;z-index:50;box-shadow:var(--shadow-sm)}
        .topbar-title{font-size:16px;font-weight:600}
        .breadcrumb{display:flex;align-items:center;gap:6px;font-size:12px;color:var(--text-light)}
        .breadcrumb a{color:var(--blue-acc);text-decoration:none}
        .breadcrumb a:hover{text-decoration:underline}
        .page-content{padding:28px;flex:1}
        .page-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:24px;gap:16px;flex-wrap:wrap}
        .page-header h1{font-size:22px;font-weight:600;color:var(--text-main)}
        .page-header p{font-size:13px;color:var(--text-sub);margin-top:3px}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border-radius:var(--radius-sm);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;text-decoration:none;transition:all var(--transition);border:none;white-space:nowrap}
        .btn-primary{background:linear-gradient(135deg,var(--navy),var(--blue-acc));color:#fff}
        .btn-secondary{background:var(--white);color:var(--text-main);border:1px solid var(--border)}
        .btn-danger{background:var(--white);color:var(--error);border:1px solid var(--error-border)}
        .btn:hover{transform:translateY(-1px)}
        .btn svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:2;flex-shrink:0}
        .toolbar{background:var(--white);border:1px solid var(--border-light);border-radius:var(--radius);padding:16px 20px;margin-bottom:20px;display:flex;flex-wrap:wrap;gap:12px;align-items:center;justify-content:space-between;box-shadow:var(--shadow-sm)}
        .search-wrap{position:relative;flex:1;min-width:220px;max-width:420px}
        .search-wrap svg{position:absolute;left:11px;top:50%;transform:translateY(-50%);width:15px;height:15px;stroke:var(--text-light);fill:none;stroke-width:1.8;pointer-events:none}
        .search-wrap input{width:100%;padding:8px 12px 8px 36px;font-family:inherit;font-size:13px;color:var(--text-main);background:var(--cloud);border:1.5px solid var(--border);border-radius:var(--radius-sm);outline:none}
        .table-card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border-light);box-shadow:var(--shadow-sm);overflow:hidden}
        .table-scroll{overflow-x:auto}
        .data-table{width:100%;border-collapse:collapse;min-width:860px}
        .data-table th{padding:11px 16px;font-size:11px;font-weight:600;color:var(--text-light);text-transform:uppercase;letter-spacing:.08em;text-align:left;background:var(--cloud);border-bottom:1px solid var(--border-light);white-space:nowrap}
        .data-table td{padding:13px 16px;font-size:13px;color:var(--text-main);border-bottom:1px solid var(--border-light);vertical-align:middle}
        .data-table tr:hover td{background:#fafbfe}
        .action-btns{display:flex;gap:6px;align-items:center}
        .action-btn{width:30px;height:30px;border-radius:6px;border:1px solid var(--border);background:var(--white);display:flex;align-items:center;justify-content:center;cursor:pointer;text-decoration:none;transition:all var(--transition)}
        .action-btn svg{width:13px;height:13px;fill:none;stroke-width:2}
        .action-btn.restore{color:var(--success)}
        .action-btn.restore:hover{background:var(--success-bg);border-color:#a8dece}
        .action-btn.restore svg{stroke:var(--success)}
        .action-btn.delete{color:var(--error)}
        .action-btn.delete:hover{background:var(--error-bg);border-color:var(--error-border)}
        .action-btn.delete svg{stroke:var(--error)}
        .prisoner-photo{width:46px;height:46px;border-radius:12px;object-fit:cover;border:1px solid var(--border);background:linear-gradient(135deg,#f7f9fd,#e8edf7)}
        .empty-state{text-align:center;padding:60px 20px}
        .empty-state svg{width:48px;height:48px;stroke:var(--text-light);fill:none;stroke-width:1.3;margin-bottom:12px}
        .empty-state h3{font-size:15px;font-weight:500;color:var(--text-sub);margin-bottom:6px}
        .empty-state p{font-size:13px;color:var(--text-light)}
        .cb{accent-color:var(--blue-acc);width:15px;height:15px}
        .pagination{display:flex;align-items:center;justify-content:space-between;padding:14px 20px;border-top:1px solid var(--border-light);flex-wrap:wrap;gap:10px}
        .pagination-info{font-size:12.5px;color:var(--text-sub)}
        .pagination-btns{display:flex;gap:4px}
        .page-btn{min-width:32px;height:32px;padding:0 6px;border:1px solid var(--border);background:var(--white);border-radius:6px;font-family:inherit;font-size:13px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all var(--transition);color:var(--text-main)}
        .page-btn.active{background:var(--navy);color:#fff;border-color:var(--navy)}
        .page-btn:disabled{opacity:.4;cursor:not-allowed}
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(26,39,68,.5);z-index:200;align-items:center;justify-content:center;padding:20px}
        .modal-overlay.show{display:flex}
        .modal{background:var(--white);border-radius:var(--radius);padding:28px;max-width:420px;width:100%;box-shadow:0 20px 60px rgba(26,39,68,.25)}
        .modal h3{font-size:16px;font-weight:600;color:var(--text-main);margin-bottom:8px}
        .modal p{font-size:13.5px;color:var(--text-sub);line-height:1.6;margin-bottom:20px}
        .modal-actions{display:flex;gap:10px;justify-content:flex-end}
        @media(max-width:900px){
            .sidebar{transform:translateX(-100%)}
            .main-wrapper{margin-left:0}
            .page-content{padding:16px}
        }
    </style>
</head>
<body>
<div class="layout">
    <nav class="sidebar">
        <div class="sidebar-logo">
            <div class="sidebar-logo-inner">
                <div class="logo-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <div class="logo-text"><h2>PMS Nepal</h2><p><%= "ADMIN".equals(role) ? "Admin Portal" : "Staff Portal" %></p></div>
            </div>
        </div>
        <div class="sidebar-nav">
            <p class="nav-section-label">Overview</p>
            <a href="<%= contextPath %>/admin-dashboard" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>Dashboard</a>
            <p class="nav-section-label" style="margin-top:8px">Management</p>
            <a href="<%= contextPath %>/prisoner-list" class="nav-item">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>Prisoners</a>
            <a href="<%= contextPath %>/trash" class="nav-item active">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>Trash / Restore</a>
        </div>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= userName.substring(0,1).toUpperCase() %></div>
                <div class="user-details"><p><%= userName %></p><span><%= role %></span></div>
                <a href="<%= contextPath %>/logout" class="logout-btn"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></a>
            </div>
        </div>
    </nav>

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Trash / Restore</div>
                <div class="breadcrumb">
                    <a href="<%= contextPath %>/admin-dashboard">Dashboard</a>
                    <span>›</span><span>Trash / Restore</span>
                </div>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Trash Bin</h1>
                    <p>Restore prisoners that were moved to trash or remove them permanently.</p>
                </div>
            </div>

            <div class="toolbar">
                <div class="search-wrap">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" id="searchInput" placeholder="Search trash..." oninput="applyFilters()">
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <button class="btn btn-secondary" id="bulkRestoreBtn" style="display:none" onclick="bulkRestore()">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 12 9 6 13 10"/><path d="M21 12a9 9 0 0 1-9 9H7"/></svg>
                        Restore Selected
                    </button>
                    <button class="btn btn-danger" id="bulkDeleteBtn" style="display:none" onclick="bulkDeleteForever()">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                        Delete Permanently
                    </button>
                </div>
            </div>

            <div class="table-card">
                <div class="table-scroll">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width:40px"><input type="checkbox" class="cb" id="selectAll" onchange="toggleSelectAll(this)"></th>
                                <th style="width:72px">Photo</th>
                                <th>Prisoner ID</th>
                                <th>Name</th>
                                <th>Crime</th>
                                <th>Deleted At</th>
                                <th>Reason</th>
                                <th style="width:120px">Action</th>
                            </tr>
                        </thead>
                        <tbody id="trashTbody">
                            <tr><td colspan="8" style="text-align:center;padding:40px"><div style="display:inline-block;width:28px;height:28px;border:3px solid var(--border);border-top-color:var(--blue-acc);border-radius:50%;animation:spin .7s linear infinite"></div></td></tr>
                        </tbody>
                    </table>
                </div>
                <div class="pagination">
                    <span class="pagination-info" id="paginationInfo"></span>
                    <div class="pagination-btns" id="paginationBtns"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <h3>Delete Permanently?</h3>
        <p>This will remove the prisoner from trash and cannot be restored later.</p>
        <div class="modal-actions">
            <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
            <button class="btn btn-danger" onclick="confirmDelete()">Delete</button>
        </div>
    </div>
</div>

<style>@keyframes spin{to{transform:rotate(360deg)}}</style>

<script>
    let allTrashed = <%= trashedJson %>;
    let filteredTrashed = [];
    let currentPage = 1;
    let deleteTargetId = null;

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function renderThumb(p) {
        if (p.photoDataUri) {
            return '<img class="prisoner-photo" src="' + p.photoDataUri + '" alt="photo">';
        }
        return '<div style="width:46px;height:46px;border-radius:12px;border:1px solid var(--border);background:linear-gradient(135deg,#f7f9fd,#e8edf7);display:flex;align-items:center;justify-content:center;color:var(--text-light)">' +
            '<svg viewBox="0 0 24 24" style="width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5h16v14H4z"/><circle cx="12" cy="10" r="3"/><path d="M4 17l5-5 4 4 3-3 4 4"/></svg>' +
            '</div>';
    }

    function applyFilters() {
        const search = document.getElementById('searchInput').value.toLowerCase().trim();
        filteredTrashed = allTrashed.filter(function(p) {
            if (!search) return true;
            return (p.fullName || '').toLowerCase().includes(search) ||
                (p.prisonerId || '').toLowerCase().includes(search) ||
                (p.crimeType || '').toLowerCase().includes(search) ||
                (p.reason || '').toLowerCase().includes(search);
        });
        currentPage = 1;
        renderTable();
    }

    function renderTable() {
        const perPage = 10;
        const start = (currentPage - 1) * perPage;
        const pageData = filteredTrashed.slice(start, start + perPage);
        const tbody = document.getElementById('trashTbody');
        document.getElementById('paginationInfo').textContent = filteredTrashed.length > 0 ? 'Showing ' + (start + 1) + '–' + Math.min(currentPage * perPage, filteredTrashed.length) + ' of ' + filteredTrashed.length : '';

        if (pageData.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state">' +
                '<svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>' +
                '<h3>No trashed prisoners</h3><p>Deleted prisoners will appear here.</p>' +
                '</div></td></tr>';
        } else {
            tbody.innerHTML = pageData.map(function(p) {
                return '<tr>' +
                    '<td><input type="checkbox" class="cb row-cb" value="' + p.prisonerId + '" onchange="updateBulkButtons()"></td>' +
                    '<td>' + renderThumb(p) + '</td>' +
                    '<td>' + escapeHtml(p.prisonerId) + '</td>' +
                    '<td style="font-weight:500">' + escapeHtml(p.fullName) + '</td>' +
                    '<td>' + escapeHtml(p.crimeType) + '</td>' +
                    '<td style="color:var(--text-sub);font-size:12.5px">' + escapeHtml(p.deletedAt) + '</td>' +
                    '<td>' + escapeHtml(p.reason) + '</td>' +
                    '<td><div class="action-btns">' +
                    '<button type="button" class="action-btn restore" title="Restore" onclick="restorePrisoner(\'' + p.prisonerId + '\')">' +
                    '<svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 12 9 6 13 10"/><path d="M21 12a9 9 0 0 1-9 9H7"/></svg>' +
                    '</button>' +
                    '<button type="button" class="action-btn delete" title="Delete permanently" onclick="openDeleteModal(\'' + p.prisonerId + '\')">' +
                    '<svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>' +
                    '</button>' +
                    '</div></td>' +
                    '</tr>';
            }).join('');
        }

        document.getElementById('bulkRestoreBtn').style.display = filteredTrashed.length ? 'inline-flex' : 'none';
        document.getElementById('bulkDeleteBtn').style.display = filteredTrashed.length ? 'inline-flex' : 'none';
        renderPagination(perPage);
        updateBulkButtons();
    }

    function renderPagination(perPage) {
        const total = filteredTrashed.length;
        const totalPages = Math.ceil(total / perPage);
        const btns = document.getElementById('paginationBtns');
        let html = '<button class="page-btn" onclick="goPage(' + (currentPage - 1) + ')" ' + (currentPage === 1 ? 'disabled' : '') + '>‹</button>';
        for (let i = 1; i <= totalPages; i++) {
            if (i === 1 || i === totalPages || (i >= currentPage - 1 && i <= currentPage + 1)) {
                html += '<button class="page-btn ' + (i === currentPage ? 'active' : '') + '" onclick="goPage(' + i + ')">' + i + '</button>';
            }
        }
        html += '<button class="page-btn" onclick="goPage(' + (currentPage + 1) + ')" ' + (currentPage === totalPages || totalPages === 0 ? 'disabled' : '') + '>›</button>';
        btns.innerHTML = html;
    }

    function goPage(page) {
        const perPage = 10;
        const totalPages = Math.ceil(filteredTrashed.length / perPage);
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTable();
    }

    function toggleSelectAll(cb) {
        document.querySelectorAll('.row-cb').forEach(function(node) {
            node.checked = cb.checked;
        });
        updateBulkButtons();
    }

    function updateBulkButtons() {
        const checked = document.querySelectorAll('.row-cb:checked').length;
        const total = document.querySelectorAll('.row-cb').length;
        document.getElementById('selectAll').checked = total > 0 && checked === total;
        document.getElementById('selectAll').indeterminate = checked > 0 && checked < total;
    }

    function selectedIds() {
        return [...document.querySelectorAll('.row-cb:checked')].map(function(cb) { return cb.value; });
    }

    function restorePrisoner(prisonerId) {
        fetch('<%= contextPath %>/trash', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            body: 'action=restore&prisonerId=' + encodeURIComponent(prisonerId)
        }).then(function() { window.location.reload(); });
    }

    function bulkRestore() {
        const ids = selectedIds();
        if (!ids.length) return;
        fetch('<%= contextPath %>/trash', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            body: 'action=bulkRestore&ids=' + encodeURIComponent(ids.join(','))
        }).then(function() { window.location.reload(); });
    }

    function openDeleteModal(id) {
        deleteTargetId = id;
        document.getElementById('deleteModal').classList.add('show');
    }

    function closeModal() {
        deleteTargetId = null;
        document.getElementById('deleteModal').classList.remove('show');
    }

    function confirmDelete() {
        if (!deleteTargetId) return;
        fetch('<%= contextPath %>/trash', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            body: 'action=permanentDelete&prisonerId=' + encodeURIComponent(deleteTargetId)
        }).then(function() {
            closeModal();
            window.location.reload();
        });
    }

    function bulkDeleteForever() {
        const ids = selectedIds();
        if (!ids.length) return;
        if (!confirm('Delete ' + ids.length + ' prisoner(s) permanently?')) return;
        fetch('<%= contextPath %>/trash', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            body: 'action=bulkPermanentDelete&ids=' + encodeURIComponent(ids.join(','))
        }).then(function() { window.location.reload(); });
    }

    applyFilters();
</script>
</body>
</html>
