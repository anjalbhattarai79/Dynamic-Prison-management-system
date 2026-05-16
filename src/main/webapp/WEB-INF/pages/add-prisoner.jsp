<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.anjal.model.User" %>
<%
    String contextPath = request.getContextPath();
    String errorMsg = (String) request.getAttribute("errorMsg");
    String successMsg = (String) request.getAttribute("successMsg");
    
    // Preserve form data on error
    String fullName = (String) request.getAttribute("fullName");
    String dateOfBirth = (String) request.getAttribute("dateOfBirth");
    String gender = (String) request.getAttribute("gender");
    String crimeType = (String) request.getAttribute("crimeType");
    String sentenceYears = (String) request.getAttribute("sentenceYears");
    String admissionDate = (String) request.getAttribute("admissionDate");
    String releaseDate = (String) request.getAttribute("releaseDate");
    String blockNumber = (String) request.getAttribute("blockNumber");
    String securityLevel = (String) request.getAttribute("securityLevel");
    String status = (String) request.getAttribute("status");
    String emergencyContact = (String) request.getAttribute("emergencyContact");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Prisoner | PMS Nepal</title>
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
            <div class="topbar-title">Add New Prisoner Record</div>
        </div>

        <div class="page-content">
            <% if(errorMsg != null) { %><div class="alert alert-error"><%= errorMsg %></div><% } %>
            <% if(successMsg != null) { %><div class="alert alert-success"><%= successMsg %></div><% } %>

            <div class="form-card">
                <form action="<%= contextPath %>/add-prisoner" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="section-title">Personal Information</div>
                    <div class="form-grid">
                        <div class="form-group span-2">
                            <label>Full Name *</label>
                            <input type="text" name="fullName" value="<%= fullName != null ? fullName : "" %>" required placeholder="Enter full legal name">
                        </div>
                        <div class="form-group">
                            <label>Date of Birth *</label>
                            <input type="date" name="dateOfBirth" value="<%= dateOfBirth != null ? dateOfBirth : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label>Gender *</label>
                            <select name="gender" required>
                                <option value="">Select Gender</option>
                                <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <div class="form-group span-2">
                            <label>Prisoner Photo</label>
                            <input type="file" name="photo" accept="image/*">
                        </div>
                    </div>

                    <div class="section-title">Legal & Incarceration Details</div>
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Crime Type *</label>
                            <input type="text" name="crimeType" value="<%= crimeType != null ? crimeType : "" %>" required placeholder="e.g. Robbery, Assault">
                        </div>
                        <div class="form-group">
                            <label>Sentence (Years) *</label>
                            <input type="number" name="sentenceYears" value="<%= sentenceYears != null ? sentenceYears : "" %>" min="1" required>
                        </div>
                        <div class="form-group">
                            <label>Admission Date *</label>
                            <input type="date" name="admissionDate" value="<%= admissionDate != null ? admissionDate : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label>Potential Release Date</label>
                            <input type="date" name="releaseDate" value="<%= releaseDate != null ? releaseDate : "" %>">
                        </div>
                        <div class="form-group">
                            <label>Block Number *</label>
                            <input type="text" name="blockNumber" value="<%= blockNumber != null ? blockNumber : "" %>" required placeholder="e.g. Block A">
                        </div>
                        <div class="form-group">
                            <label>Security Level *</label>
                            <select name="securityLevel" required>
                                <option value="Low" <%= "Low".equals(securityLevel) ? "selected" : "" %>>Low Security</option>
                                <option value="Medium" <%= "Medium".equals(securityLevel) ? "selected" : "" %>>Medium Security</option>
                                <option value="High" <%= "High".equals(securityLevel) ? "selected" : "" %>>High Security</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Initial Status *</label>
                            <select name="status" required>
                                <option value="Active" <%= "Active".equals(status) ? "selected" : "" %>>Active</option>
                                <option value="Transferred" <%= "Transferred".equals(status) ? "selected" : "" %>>Transferred</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Emergency Contact</label>
                            <input type="text" name="emergencyContact" value="<%= emergencyContact != null ? emergencyContact : "" %>" placeholder="Name and Phone">
                        </div>
                    </div>

                    <div class="submit-bar">
                        <a href="<%= contextPath %>/prisoner-list" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Register Prisoner</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>
