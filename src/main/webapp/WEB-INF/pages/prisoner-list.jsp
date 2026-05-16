<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String prisonersJson = (String) request.getAttribute("prisonersJson");
    if (prisonersJson == null || prisonersJson.trim().isEmpty()) {
        prisonersJson = "[]";
    }
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prisoner Management | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
        <style>
            .action-btns { display: flex; gap: 5px; }
            .data-table th.actions-col, .data-table td.actions-col { width: 220px; min-width: 220px; }
            .prisoner-photo { width: 40px; height: 40px; border-radius: 8px; object-fit: cover; }
            .modal-lg { max-width: 800px; }
            .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
            .form-group { display: flex; flex-direction: column; gap: 5px; margin-bottom: 10px; }
            .form-group label { font-size: 11px; font-weight: 600; color: var(--text-light); text-transform: uppercase; }
        </style>
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/pages/common/sidebar.jsp" />
    <div class="main-wrapper">
        <div class="topbar">
            <button class="mobile-menu-btn" onclick="openSidebar()">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            </button>
            <div>
                <div class="topbar-title">Prisoner Management</div>
                <div class="breadcrumb">
                    <a href="<%= contextPath %>/admin-dashboard">Dashboard</a>
                    <span>›</span><span>Prisoners</span>
                </div>
            </div>
            <div class="topbar-right">
                <a href="<%= contextPath %>/add-prisoner" class="btn btn-primary btn-sm">Add Prisoner</a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Prisoners</h1>
                    <p>Manage and search all prisoner records</p>
                </div>
                <div class="page-header-actions">
                    <button class="btn btn-secondary btn-sm" onclick="exportCSV()">Export CSV</button>
                    <a href="<%= contextPath %>/add-prisoner" class="btn btn-primary btn-sm">Add Prisoner</a>
                </div>
            </div>

            <!-- Filters -->
            <div class="filters-bar">
                <div class="filter-group search-wrap">
                    <label>Search</label>
                    <div class="search-wrap">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" id="searchInput" placeholder="Name or ID..." oninput="applyFilters()">
                    </div>
                </div>
                <div class="filter-group">
                    <label>Status</label>
                    <select id="filterStatus" onchange="applyFilters()">
                        <option value="">All Statuses</option>
                        <option value="Active">Active</option>
                        <option value="Released">Released</option>
                        <option value="Transferred">Transferred</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Block</label>
                    <select id="filterBlock" onchange="applyFilters()">
                        <option value="">All Blocks</option>
                        <option value="A">Block A</option><option value="B">Block B</option><option value="C">Block C</option><option value="D">Block D</option>
                    </select>
                </div>
                <button class="btn btn-secondary btn-sm" onclick="clearFilters()">Clear</button>
            </div>

            <!-- Table -->
            <div class="table-card">
                <table class="data-table" id="prisonerTable">
                    <thead>
                        <tr>
                            <th class="checkbox-col"><input type="checkbox" id="selectAll" onchange="toggleSelectAll(this)"></th>
                            <th class="photo-col">Photo</th>
                            <th>ID</th>
                            <th>Full Name</th>
                            <th>Crime Type</th>
                            <th>Block</th>
                            <th>Status</th>
                            <th class="actions-col">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="prisonerTbody"></tbody>
                </table>
                <div class="pagination">
                    <span id="paginationInfo" class="pagination-info"></span>
                    <div id="paginationBtns" class="pagination-btns"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal -->
<div class="modal-overlay" id="prisonerModal">
    <div class="modal">
        <div class="modal-header">
            <h3 id="modalTitle">Prisoner Details</h3>
            <button class="modal-close" onclick="closePrisonerModal()"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>
        </div>
        <div class="photo-shell"><img id="viewPhoto" class="prisoner-photo-lg" alt="photo"></div>
        <div class="details-grid">
            <div class="detail-item"><label class="detail-label">ID</label><span id="viewPrisonerId" class="detail-value"></span></div>
            <div class="detail-item"><label class="detail-label">Name</label><span id="viewFullName" class="detail-value"></span></div>
            <div class="detail-item"><label class="detail-label">Status</label><span id="viewStatus" class="detail-value"></span></div>
            <div class="detail-item"><label class="detail-label">Block</label><span id="viewBlockNumber" class="detail-value"></span></div>
        </div>
        <div class="modal-actions">
            <button class="btn btn-secondary" onclick="closePrisonerModal()">Close</button>
        </div>
    </div>
</div>

<script>
    let allPrisoners = <%= prisonersJson %>;
    let filteredPrisoners = [];
    let currentPage = 1;
    const perPage = 10;

    function applyFilters() {
        const search = document.getElementById('searchInput').value.toLowerCase();
        const status = document.getElementById('filterStatus').value;
        const block = document.getElementById('filterBlock').value;
        filteredPrisoners = allPrisoners.filter(p => {
            return (!search || p.fullName.toLowerCase().includes(search) || p.prisonerId.toLowerCase().includes(search)) &&
                   (!status || p.status === status) && (!block || p.blockNumber === block);
        });
        currentPage = 1;
        renderTable();
    }

    function renderTable() {
        const start = (currentPage - 1) * perPage;
        const pageData = filteredPrisoners.slice(start, start + perPage);
        const tbody = document.getElementById('prisonerTbody');
        
        if (pageData.length === 0) {
            tbody.innerHTML = `<tr><td colspan="8" class="empty-state">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <h3>No prisoners found</h3>
                <p>Try adjusting your search or filter criteria</p>
            </td></tr>`;
        } else {
            tbody.innerHTML = pageData.map(p => `
                <tr>
                    <td><input type="checkbox"></td>
                    <td>\${p.photoDataUri ? `<img class="prisoner-photo" src="\${p.photoDataUri}">` : `<div class="prisoner-photo" style="background:#eee"></div>`}</td>
                    <td><code>\${p.prisonerId}</code></td>
                    <td style="font-weight:500">\${p.fullName}</td>
                    <td>\${p.crimeType}</td>
                    <td>Block \${p.blockNumber}</td>
                    <td><span class="badge badge-\${p.status.toLowerCase()}">\${p.status}</span></td>
                    <td class="actions-col">
                        <div class="action-btns">
                            <button class="btn btn-secondary btn-sm" onclick="openPrisonerModal('\${p.prisonerId}')">View</button>
                            <button class="btn btn-primary btn-sm" onclick="openEditModal('\${p.prisonerId}')">Edit</button>
                            <button class="btn btn-danger btn-sm" onclick="deletePrisoner('\${p.prisonerId}')">Delete</button>
                        </div>
                    </td>
                </tr>
            `).join('');
        }
        renderPagination();
    }

    function renderPagination() {
        const total = filteredPrisoners.length;
        const totalPages = Math.ceil(total / perPage);
        document.getElementById('paginationInfo').textContent = `Showing \${filteredPrisoners.length > 0 ? (currentPage-1)*perPage+1 : 0} to \${Math.min(currentPage*perPage, total)} of \${total}`;
        let btns = '';
        for(let i=1; i<=totalPages; i++) btns += `<button class="btn \${i===currentPage?'btn-primary':'btn-secondary'} btn-sm" onclick="currentPage=\${i};renderTable()">\${i}</button>`;
        document.getElementById('paginationBtns').innerHTML = btns;
    }

    function openPrisonerModal(id) {
        const p = allPrisoners.find(x => x.prisonerId === id);
        if(!p) return;
        document.getElementById('viewPrisonerId').textContent = p.prisonerId;
        document.getElementById('viewFullName').textContent = p.fullName;
        document.getElementById('viewStatus').textContent = p.status;
        document.getElementById('viewBlockNumber').textContent = p.blockNumber;
        document.getElementById('viewPhoto').src = p.photoDataUri || '';
        
        // Add footer actions to view modal
        const modalActions = document.querySelector('#prisonerModal .modal-actions');
        modalActions.innerHTML = `
            <button class="btn btn-primary" onclick="closePrisonerModal(); openEditModal('${p.prisonerId}')">Edit Details</button>
            <button class="btn btn-danger" onclick="closePrisonerModal(); deletePrisoner('${p.prisonerId}')">Delete Prisoner</button>
            <button class="btn btn-secondary" onclick="closePrisonerModal()">Close</button>
        `;
        
        document.getElementById('prisonerModal').classList.add('show');
    }

    function openEditModal(id) {
        const p = allPrisoners.find(x => x.prisonerId === id);
        if(!p) return;
        
        document.getElementById('editPrisonerId').value = p.prisonerId;
        document.getElementById('editFullName').value = p.fullName;
        document.getElementById('editCrimeType').value = p.crimeType;
        document.getElementById('editSentenceYears').value = p.sentenceYears;
        document.getElementById('editBlockNumber').value = p.blockNumber;
        document.getElementById('editSecurityLevel').value = p.securityLevel;
        document.getElementById('editStatus').value = p.status;
        document.getElementById('editEmergencyContact').value = p.emergencyContact;
        document.getElementById('editDateOfBirth').value = p.dateOfBirth;
        document.getElementById('editAdmissionDate').value = p.admissionDate;
        document.getElementById('editReleaseDate').value = p.releaseDate;
        document.getElementById('editGender').value = p.gender;

        document.getElementById('editModal').classList.add('show');
    }

    function closeEditModal() { document.getElementById('editModal').classList.remove('show'); }

    function updatePrisoner(event) {
        event.preventDefault();
        const id = document.getElementById('editPrisonerId').value;
        const formData = new URLSearchParams(new FormData(event.target));
        formData.append('action', 'update');
        formData.append('prisonerId', id);

        fetch('<%= contextPath %>/prisoner-list', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: formData.toString()
        }).then(res => res.json())
          .then(data => {
              if(data.success) {
                  window.location.reload();
              } else {
                  alert(data.error || 'Failed to update prisoner');
              }
          });
    }

    function deletePrisoner(id) {
        if(!confirm('Are you sure you want to delete this prisoner? This will move them to trash.')) return;
        
        fetch('<%= contextPath %>/prisoner-list', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=softDelete&prisonerId=' + id
        }).then(res => res.json())
          .then(data => {
              if(data.success) {
                  window.location.reload();
              } else {
                  alert('Failed to delete prisoner');
              }
          });
    }

    function toggleSelectAll(master) {
        const checkboxes = document.querySelectorAll('#prisonerTbody input[type="checkbox"]');
        checkboxes.forEach(cb => cb.checked = master.checked);
    }

    function closePrisonerModal() { document.getElementById('prisonerModal').classList.remove('show'); }
    function clearFilters() { document.getElementById('searchInput').value=''; document.getElementById('filterStatus').value=''; document.getElementById('filterBlock').value=''; applyFilters(); }
    function exportCSV() { window.location.href = '<%= contextPath %>/prisoner-list?action=export'; }

    applyFilters();
</script>

<!-- Edit Modal -->
<div class="modal-overlay" id="editModal">
    <div class="modal modal-lg">
        <div class="modal-header">
            <h3>Edit Prisoner Details</h3>
            <button class="modal-close" onclick="closeEditModal()"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>
        </div>
        <form onsubmit="updatePrisoner(event)">
            <input type="hidden" id="editPrisonerId">
            <div class="details-grid">
                <div class="form-group"><label>Full Name</label><input type="text" id="editFullName" name="fullName" required></div>
                <div class="form-group"><label>Gender</label>
                    <select id="editGender" name="gender">
                        <option value="Male">Male</option><option value="Female">Female</option><option value="Other">Other</option>
                    </select>
                </div>
                <div class="form-group"><label>Date of Birth</label><input type="date" id="editDateOfBirth" name="dateOfBirth"></div>
                <div class="form-group"><label>Crime Type</label><input type="text" id="editCrimeType" name="crimeType"></div>
                <div class="form-group"><label>Sentence (Years)</label><input type="number" id="editSentenceYears" name="sentenceYears"></div>
                <div class="form-group"><label>Admission Date</label><input type="date" id="editAdmissionDate" name="admissionDate"></div>
                <div class="form-group"><label>Release Date</label><input type="date" id="editReleaseDate" name="releaseDate"></div>
                <div class="form-group"><label>Block</label><input type="text" id="editBlockNumber" name="blockNumber"></div>
                <div class="form-group"><label>Security Level</label>
                    <select id="editSecurityLevel" name="securityLevel">
                        <option value="Low">Low</option><option value="Medium">Medium</option><option value="High">High</option>
                    </select>
                </div>
                <div class="form-group"><label>Status</label>
                    <select id="editStatus" name="status">
                        <option value="Active">Active</option><option value="Released">Released</option><option value="Transferred">Transferred</option>
                    </select>
                </div>
                <div class="form-group"><label>Emergency Contact</label><input type="text" id="editEmergencyContact" name="emergencyContact"></div>
            </div>
            <div class="modal-actions">
                <button type="submit" class="btn btn-primary">Save Changes</button>
                <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Cancel</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
