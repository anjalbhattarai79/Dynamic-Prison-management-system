<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PMS Nepal | Secure Portal Login</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy: #1a2744;
            --navy-mid: #243358;
            --blue-acc: #3a6fd8;
            --blue-light: #4f85ec;
            --steel: #5a7099;
            --cloud: #f4f6fb;
            --white: #ffffff;
            --border: #d0d9ee;
            --error: #c94040;
            --success: #1e7d5a;
            --radius: 12px;
            --shadow: 0 10px 40px rgba(26,39,68,0.08);
            --transition: .2s ease;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--cloud);
            display: flex;
            min-height: 100vh;
            color: var(--navy);
        }

        /* Split Screen Layout */
        .login-container {
            display: flex;
            width: 100%;
        }

        /* Branding Side */
        .branding-side {
            flex: 1.2;
            background: var(--navy);
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 80px;
            color: white;
            position: relative;
            overflow: hidden;
        }

        .branding-side::before {
            content: '';
            position: absolute;
            top: -100px;
            right: -100px;
            width: 400px;
            height: 400px;
            background: rgba(58,111,216,0.1);
            border-radius: 50%;
        }

        .branding-content { position: relative; z-index: 2; }

        .logo-box {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 40px;
        }

        .logo-icon {
            width: 50px;
            height: 50px;
            background: rgba(255,255,255,0.1);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .logo-icon svg { width: 28px; height: 28px; stroke: white; fill: none; stroke-width: 2; }

        .logo-text h1 {
            font-family: 'Playfair Display', serif;
            font-size: 24px;
            letter-spacing: -0.02em;
        }

        .logo-text p {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.15em;
            opacity: 0.6;
            margin-top: 2px;
        }

        .hero-text h2 {
            font-size: 42px;
            line-height: 1.2;
            margin-bottom: 20px;
            font-weight: 700;
        }

        .hero-text p {
            font-size: 18px;
            opacity: 0.7;
            max-width: 450px;
            line-height: 1.6;
        }

        /* Form Side */
        .form-side {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            background: var(--cloud);
        }

        .login-card {
            background: var(--white);
            width: 100%;
            max-width: 440px;
            padding: 48px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid rgba(208, 217, 238, 0.5);
        }

        .card-header { margin-bottom: 32px; }
        .card-header h3 { font-size: 24px; font-weight: 700; margin-bottom: 8px; }
        .card-header p { color: var(--steel); font-size: 14px; }

        /* Alerts */
        .alert {
            padding: 14px 16px;
            border-radius: 8px;
            font-size: 13.5px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #f5c0c0;
            color: var(--error);
        }

        .alert-success {
            background: #edf7f3;
            border: 1px solid #a8dece;
            color: var(--success);
        }

        /* Form Groups */
        .field-group { margin-bottom: 20px; }
        
        label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--steel);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        .input-wrap { position: relative; }

        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            width: 18px;
            height: 18px;
            stroke: var(--steel);
            opacity: 0.6;
        }

        input, select {
            width: 100%;
            padding: 12px 14px 12px 42px;
            border: 1.5px solid var(--border);
            border-radius: 8px;
            font-size: 15px;
            font-family: inherit;
            color: var(--navy);
            outline: none;
            transition: all var(--transition);
            background: var(--white);
        }

        select { cursor: pointer; }

        input:focus, select:focus {
            border-color: var(--blue-acc);
            box-shadow: 0 0 0 4px rgba(58, 111, 216, 0.1);
        }

        .forgot-link {
            display: block;
            text-align: right;
            margin-top: 8px;
            font-size: 13px;
            color: var(--blue-acc);
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-link:hover { text-decoration: underline; }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--navy), var(--navy-mid));
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all var(--transition);
            box-shadow: 0 4px 12px rgba(26, 39, 68, 0.2);
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(26, 39, 68, 0.25);
            background: var(--navy-mid);
        }

        .btn-login:active { transform: translateY(0); }

        .btn-login:disabled {
            background: var(--steel);
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
        }

        /* Spinner */
        .spinner {
            width: 18px;
            height: 18px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            display: none;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .branding-side { display: none; }
            .form-side { background: var(--white); padding: 20px; }
            .login-card { box-shadow: none; border: none; padding: 20px; }
        }
    </style>
</head>
<body>

<div class="login-container">
    <!-- Left Branding Section -->
    <div class="branding-side">
        <div class="branding-content">
            <div class="logo-box">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <div class="logo-text">
                    <h1>PMS Nepal</h1>
                    <p>Prison Management System</p>
                </div>
            </div>
            <div class="hero-text">
                <h2>Secure Centralized Portal</h2>
                <p>Ensuring transparency, safety, and efficient record management for the Department of Prison Management.</p>
            </div>
        </div>
    </div>

    <!-- Right Login Form Section -->
    <div class="form-side">
        <div class="login-card">
            <div class="card-header">
                <h3>Account Sign In</h3>
                <p>Enter your credentials to access the portal</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <svg style="width:18px;height:18px" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <% if (request.getAttribute("successMsg") != null) { %>
                <div class="alert alert-success">
                    <svg style="width:18px;height:18px" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    <%= request.getAttribute("successMsg") %>
                </div>
            <% } %>

            <form id="loginForm" action="<%= request.getContextPath() %>/login" method="POST">
                <div class="field-group">
                    <label>Portal Type</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        <select id="loginType" name="loginType" required>
                            <option value="ADMIN" <%= "ADMIN".equals(request.getAttribute("loginType")) ? "selected" : "" %>>Administrator / Staff</option>
                            <option value="FAMILY" <%= "FAMILY".equals(request.getAttribute("loginType")) ? "selected" : "" %>>Family Member Portal</option>
                        </select>
                    </div>
                </div>

                <div class="field-group">
                    <label id="idLabel">Email Address</label>
                    <div class="input-wrap">
                        <svg class="input-icon" id="userIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input type="text" id="email" name="email" value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required placeholder="your@email.com">
                    </div>
                </div>

                <div class="field-group" style="margin-bottom: 0;">
                    <label>Secure Password</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="password" name="password" required placeholder="••••••••">
                    </div>
                </div>

                <a href="<%= request.getContextPath() %>/forgot-password" class="forgot-link">Forgot your password?</a>

                <button type="submit" class="btn-login" id="loginBtn">
                    <span class="spinner" id="spinner"></span>
                    <span id="btnText">Sign In to Dashboard</span>
                </button>
            </form>
        </div>
    </div>
</div>

<script>
    const form = document.getElementById('loginForm');
    const email = document.getElementById('email');
    const label = document.getElementById('idLabel');
    const type = document.getElementById('loginType');
    const loginBtn = document.getElementById('loginBtn');
    const spinner = document.getElementById('spinner');
    const btnText = document.getElementById('btnText');
    const userIcon = document.getElementById('userIcon');

    function updatePortalUI() {
        if (type.value === 'FAMILY') {
            label.innerText = "Prisoner ID";
            email.placeholder = "e.g., NP-PMS-0611";
            // Change icon to user instead of mail
            userIcon.innerHTML = '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>';
        } else {
            label.innerText = "Email Address";
            email.placeholder = "admin@example.com";
            // Back to mail icon
            userIcon.innerHTML = '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>';
        }
    }

    type.addEventListener('change', updatePortalUI);
    
    form.addEventListener('submit', () => {
        loginBtn.disabled = true;
        spinner.style.display = 'block';
        btnText.innerText = 'Authenticating...';
    });

    // Run on init to catch any pre-selected values
    updatePortalUI();
</script>

</body>
</html>