<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Recovery | Prison Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--navy:#1a2744;--navy-mid:#243358;--blue-acc:#3a6fd8;--blue-light:#4f85ec;--steel:#5a7099;--mist:#e8edf7;--cloud:#f4f6fb;--white:#ffffff;--border:#d0d9ee;--text-main:#1a2744;--text-sub:#5a7099;--text-light:#8e9ec1;--error:#d94f4f;--error-bg:#fff0f0;--error-border:#f5c0c0;--success:#2a8a6e;--success-bg:#f0faf6;--success-border:#a8dece;--shadow-lg:0 20px 60px rgba(26,39,68,.16);--radius:14px;--radius-sm:8px;--transition:.2s ease}
        html,body{height:100%;font-family:'DM Sans',sans-serif;color:var(--text-main);background:var(--cloud)}
        body{display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;padding:24px;position:relative;overflow-x:hidden}
        body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse 80% 60% at 20% 0%,rgba(58,111,216,.10) 0%,transparent 60%),radial-gradient(ellipse 60% 50% at 80% 100%,rgba(26,39,68,.08) 0%,transparent 55%),linear-gradient(160deg,#edf0f8 0%,#f7f9fd 50%,#e8edf7 100%);z-index:0}
        body::after{content:'';position:fixed;inset:0;background-image:linear-gradient(rgba(58,111,216,.04) 1px,transparent 1px),linear-gradient(90deg,rgba(58,111,216,.04) 1px,transparent 1px);background-size:40px 40px;z-index:0}
        .page-wrapper{position:relative;z-index:1;width:100%;max-width:460px;display:flex;flex-direction:column;gap:16px}
        .system-badge{display:flex;align-items:center;justify-content:center;gap:10px;margin-bottom:4px}
        .badge-icon{width:44px;height:44px;background:linear-gradient(135deg,var(--navy),var(--navy-mid));border-radius:12px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 14px rgba(26,39,68,.30);flex-shrink:0}
        .badge-icon svg{width:22px;height:22px;fill:none;stroke:#fff;stroke-width:1.8}
        .badge-text h1{font-family:'Playfair Display',Georgia,serif;font-size:18px;font-weight:600;color:var(--navy)}
        .badge-text p{font-size:11.5px;color:var(--text-sub);letter-spacing:.06em;text-transform:uppercase;font-weight:500}
        .card{background:var(--white);border-radius:var(--radius);padding:40px 40px 36px;box-shadow:var(--shadow-lg);border:1px solid rgba(208,217,238,.6);position:relative;overflow:hidden}
        .card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;background:linear-gradient(90deg,var(--navy),var(--blue-acc),var(--blue-light));border-radius:var(--radius) var(--radius) 0 0}
        .icon-circle{width:56px;height:56px;background:linear-gradient(135deg,var(--mist),#dce5f5);border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 20px;border:2px solid var(--border)}
        .icon-circle svg{width:24px;height:24px;stroke:var(--navy-mid);fill:none;stroke-width:1.8}
        .card-title{text-align:center;margin-bottom:28px}
        .card-title h2{font-size:17px;font-weight:600;color:var(--text-main);margin-bottom:6px}
        .card-title p{font-size:13px;color:var(--text-sub);line-height:1.6;max-width:330px;margin:0 auto}
        .alert{display:none;align-items:flex-start;gap:9px;padding:11px 14px;border-radius:var(--radius-sm);margin-bottom:18px;font-size:12.5px;line-height:1.5}
        .alert.show{display:flex}
        .alert svg{width:15px;height:15px;flex-shrink:0;margin-top:1px;fill:none}
        .alert-error{background:var(--error-bg);border:1px solid var(--error-border);color:var(--error)}
        .alert-error svg{stroke:var(--error)}
        .alert-success{background:var(--success-bg);border:1px solid var(--success-border);color:var(--success)}
        .alert-success svg{stroke:var(--success)}
        .panel{display:none}
        .panel.show{display:block}
        form{display:flex;flex-direction:column;gap:18px}
        .field-group{display:flex;flex-direction:column;gap:6px}
        label{font-size:12.5px;font-weight:500;color:var(--text-sub);letter-spacing:.02em}
        .input-wrap{position:relative;display:flex;align-items:center}
        .input-icon{position:absolute;left:13px;width:16px;height:16px;stroke:var(--text-light);stroke-width:1.7;fill:none;pointer-events:none;transition:stroke var(--transition)}
        .field-group:focus-within .input-icon{stroke:var(--blue-acc)}
        input[type="email"],input[type="text"],input[type="password"]{width:100%;padding:11px 14px 11px 40px;font-family:inherit;font-size:13.5px;color:var(--text-main);background:var(--cloud);border:1.5px solid var(--border);border-radius:var(--radius-sm);outline:none;transition:border-color var(--transition),box-shadow var(--transition),background var(--transition)}
        input::placeholder{color:var(--text-light);font-size:13px}
        input:focus{border-color:var(--blue-acc);background:var(--white);box-shadow:0 0 0 3px rgba(58,111,216,.10)}
        input.invalid{border-color:var(--error)!important;background:var(--error-bg)!important;box-shadow:0 0 0 3px rgba(217,79,79,.08)!important}
        .field-error{font-size:11.5px;color:var(--error);display:none;align-items:center;gap:5px}
        .field-error.show{display:flex}
        .field-error svg{width:12px;height:12px;stroke:var(--error);fill:none;flex-shrink:0}
        .btn-primary{width:100%;padding:13px;background:linear-gradient(135deg,var(--navy) 0%,var(--blue-acc) 100%);color:var(--white);border:none;border-radius:var(--radius-sm);font-family:inherit;font-size:13.5px;font-weight:600;letter-spacing:.04em;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;transition:opacity var(--transition),transform var(--transition),box-shadow var(--transition);box-shadow:0 4px 16px rgba(58,111,216,.35);margin-top:4px}
        .btn-primary:hover:not(:disabled){opacity:.92;transform:translateY(-1px);box-shadow:0 6px 20px rgba(58,111,216,.42)}
        .btn-primary:disabled{background:linear-gradient(135deg,#aab4cc,#c2cde0);cursor:not-allowed;box-shadow:none}
        .btn-primary svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2}
        .spinner{display:none;width:16px;height:16px;border:2px solid rgba(255,255,255,.4);border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite}
        @keyframes spin{to{transform:rotate(360deg)}}
        .back-link,.switch-link{display:flex;align-items:center;justify-content:center;gap:6px;text-decoration:none;color:var(--text-sub);font-size:12.5px;font-weight:500;margin-top:8px;transition:color var(--transition)}
        .back-link:hover,.switch-link:hover{color:var(--navy)}
        .back-link svg,.switch-link svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2}
        .success-state{display:none;text-align:center;padding:10px 0}
        .success-state.show{display:block}
        .success-icon{width:64px;height:64px;background:var(--success-bg);border:2px solid var(--success-border);border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 16px}
        .success-icon svg{width:28px;height:28px;stroke:var(--success);fill:none;stroke-width:2}
        .success-state h3{font-size:16px;font-weight:600;color:var(--text-main);margin-bottom:8px}
        .success-state p{font-size:13px;color:var(--text-sub);line-height:1.6;margin-bottom:20px}
        footer{text-align:center;font-size:11px;color:var(--text-light);margin-top:6px;line-height:1.8}
        footer a{color:var(--text-light);text-decoration:none}
        footer a:hover{text-decoration:underline}
    </style>
</head>
<body>
<%
    String errorMsg = (String) request.getAttribute("errorMsg");
    String successMsg = (String) request.getAttribute("successMsg");
    Boolean showResetAttr = (Boolean) request.getAttribute("showResetForm");
    boolean showResetForm = showResetAttr != null && showResetAttr;
    String mode = request.getParameter("mode");
    if ("reset".equalsIgnoreCase(mode) || request.getParameter("token") != null) {
        showResetForm = true;
    }
    String emailValue = request.getParameter("email");
    if (emailValue == null) {
        emailValue = "";
    }
    String tokenValue = request.getParameter("token");
    if (tokenValue == null) {
        tokenValue = "";
    }
%>

<div class="page-wrapper">
    <div class="system-badge">
        <div class="badge-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M7 11V7a5 5 0 0 1 10 0v4" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="16" r="1.5" fill="white" stroke="none"/></svg>
        </div>
        <div class="badge-text">
            <h1>Prison Management System</h1>
            <p>Password Recovery &nbsp;·&nbsp; Government of Nepal</p>
        </div>
    </div>

    <div class="card">
        <div class="icon-circle">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/><circle cx="12" cy="16" r="1"/></svg>
        </div>

        <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div class="alert alert-success show">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <span><%= successMsg %></span>
        </div>
        <% } %>

        <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="alert alert-error show">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            <span><%= errorMsg %></span>
        </div>
        <% } %>

        <div id="forgotPanel" class="panel <% if (!showResetForm && (successMsg == null || successMsg.isEmpty())) { %>show<% } %>">
            <div class="card-title">
                <h2>Forgot your password?</h2>
                <p>Enter your registered email address and we will prepare a reset link for your account.</p>
            </div>

            <form id="forgotForm" action="<%= request.getContextPath() %>/forgot-password" method="POST" novalidate>
                <div class="field-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input type="email" id="email" name="email" value="<%= emailValue %>" placeholder="your@email.com" required>
                    </div>
                    <span class="field-error" id="emailErr">
                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        Please enter a valid email address
                    </span>
                </div>

                <button type="submit" class="btn-primary" id="sendBtn">
                    <div class="spinner" id="sendSpinner"></div>
                    <svg id="sendIcon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                    <span id="sendLabel">Send Reset Link</span>
                </button>
            </form>

            <a href="<%= request.getContextPath() %>/reset-password?mode=reset&email=<%= emailValue %>" class="switch-link">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                I already have a reset token
            </a>

            <a href="<%= request.getContextPath() %>/login" class="back-link" style="margin-top:16px">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                Back to Sign In
            </a>
        </div>

        <div id="resetPanel" class="panel <% if (showResetForm) { %>show<% } %>">
            <div class="card-title">
                <h2>Reset your password</h2>
                <p>Use the reset token you received to set a new password for your account.</p>
            </div>

            <form id="resetForm" action="<%= request.getContextPath() %>/reset-password" method="POST" novalidate>
                <div class="field-group">
                    <label for="resetEmail">Email Address</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input type="email" id="resetEmail" name="email" value="<%= emailValue %>" placeholder="your@email.com" required>
                    </div>
                </div>

                <div class="field-group">
                    <label for="token">Reset Token</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M9 12h6"/><path d="M12 9v6"/></svg>
                        <input type="text" id="token" name="token" value="<%= tokenValue %>" placeholder="Enter your reset token" required>
                    </div>
                </div>

                <div class="field-group">
                    <label for="newPassword">New Password</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="newPassword" name="newPassword" placeholder="New password" required>
                    </div>
                </div>

                <div class="field-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <div class="input-wrap">
                        <svg class="input-icon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password" required>
                    </div>
                </div>

                <button type="submit" class="btn-primary" id="resetBtn">
                    <div class="spinner" id="resetSpinner"></div>
                    <svg id="resetIcon" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a8 8 0 0 1 8-8h10"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a8 8 0 0 1-8 8H3"/></svg>
                    <span id="resetLabel">Reset Password</span>
                </button>
            </form>

            <a href="<%= request.getContextPath() %>/forgot-password" class="switch-link">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                Go back to email recovery
            </a>

            <a href="<%= request.getContextPath() %>/login" class="back-link" style="margin-top:16px">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                Back to Sign In
            </a>
        </div>

        <div class="success-state <% if (successMsg != null && !successMsg.isEmpty()) { %>show<% } %>">
            <div class="success-icon">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <h3>Request received</h3>
            <p>If the account details are valid, the next recovery step is ready.</p>
            <a href="<%= request.getContextPath() %>/login" class="btn-primary" style="text-decoration:none">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                Return to Login
            </a>
        </div>
    </div>

    <footer>
        &copy; 2026 Prison Management System &nbsp;|&nbsp; All Rights Reserved<br>
        <a href="#">Privacy Policy</a> &nbsp;&middot;&nbsp; <a href="#">Contact Support</a>
    </footer>
</div>

<script>
    const forgotForm = document.getElementById('forgotForm');
    const emailEl = document.getElementById('email');
    const emailErr = document.getElementById('emailErr');
    const resetForm = document.getElementById('resetForm');
    const resetEmailEl = document.getElementById('resetEmail');
    const tokenEl = document.getElementById('token');
    const newPasswordEl = document.getElementById('newPassword');
    const confirmPasswordEl = document.getElementById('confirmPassword');

    if (emailEl) {
        emailEl.addEventListener('blur', () => {
            const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailEl.value.trim());
            if (emailEl.value && !valid) {
                emailEl.classList.add('invalid');
                emailErr.classList.add('show');
            } else {
                emailEl.classList.remove('invalid');
                emailErr.classList.remove('show');
            }
        });
    }

    if (forgotForm) {
        forgotForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailEl.value.trim());
            if (!valid) {
                emailEl.classList.add('invalid');
                emailErr.classList.add('show');
                return;
            }
            const btn = document.getElementById('sendBtn');
            document.getElementById('sendSpinner').style.display = 'block';
            document.getElementById('sendIcon').style.display = 'none';
            document.getElementById('sendLabel').textContent = 'Sending…';
            btn.disabled = true;
            this.submit();
        });
    }

    if (resetForm) {
        resetForm.addEventListener('submit', function(e) {
            const emailValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(resetEmailEl.value.trim());
            if (!emailValid || !tokenEl.value.trim() || !newPasswordEl.value || !confirmPasswordEl.value) {
                e.preventDefault();
                return;
            }
            if (newPasswordEl.value !== confirmPasswordEl.value) {
                e.preventDefault();
                confirmPasswordEl.classList.add('invalid');
                return;
            }
            const btn = document.getElementById('resetBtn');
            document.getElementById('resetSpinner').style.display = 'block';
            document.getElementById('resetIcon').style.display = 'none';
            document.getElementById('resetLabel').textContent = 'Resetting…';
            btn.disabled = true;
        });
    }
</script>
</body>
</html>
