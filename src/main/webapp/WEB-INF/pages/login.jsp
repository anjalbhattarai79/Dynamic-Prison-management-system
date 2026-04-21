<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PMS | Secure Login</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy: #1a2744; --blue-acc: #3a6fd8; --border: #d0d9ee;
            --white: #ffffff; --error: #d94f4f; --radius: 12px;
            --transition: .2s ease;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: #f4f6fb;
            display: flex; justify-content: center; align-items: center;
            min-height: 100vh; margin: 0;
        }

        .card {
            background: var(--white); width: 100%; max-width: 420px;
            padding: 40px; border-radius: var(--radius);
            box-shadow: 0 10px 40px rgba(26,39,68,0.1);
            border-top: 4px solid var(--navy);
        }

        .alert {
            background: #fff0f0; border: 1px solid #f5c0c0;
            color: var(--error); padding: 12px; border-radius: 8px;
            margin-bottom: 20px; font-size: 13px; display: none;
        }
        .alert.show { display: block; }

        .field-group { margin-bottom: 18px; display: flex; flex-direction: column; gap: 8px; }
        
        label { font-size: 13px; font-weight: 500; color: #5a7099; }

        input, select {
            padding: 12px; border: 1.5px solid var(--border);
            border-radius: 8px; font-size: 14px; outline: none;
            transition: all var(--transition);
        }

        input:focus, select:focus {
            border-color: var(--blue-acc); box-shadow: 0 0 0 3px rgba(58,111,216,0.1);
        }

        .btn-login {
            width: 100%; padding: 14px; background: var(--navy);
            color: white; border: none; border-radius: 8px;
            font-weight: 600; cursor: pointer; margin-top: 10px;
            transition: opacity 0.2s;
        }

        .btn-login:disabled { background: #aab4cc; cursor: not-allowed; }
        
        .loading-text { display: none; }
    </style>
</head>
<body>

<div class="card">
    <h2 style="margin-bottom: 8px;">Portal Login</h2>
    <p style="color: #8e9ec1; font-size: 14px; margin-bottom: 24px;">Government of Nepal | Prison Management</p>

    <div class="alert <%= request.getAttribute("error") != null ? "show" : "" %>">
        <%= request.getAttribute("error") %>
    </div>

    <form id="loginForm" action="<%= request.getContextPath() %>/login" method="POST">
        <div class="field-group">
            <label>Email Address</label>
            <input type="email" id="email" name="email" value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
        </div>

        <div class="field-group">
            <label>Password</label>
            <input type="password" id="password" name="password" required>
        </div>

        <div class="field-group">
            <label>Login As</label>
            <select id="loginType" name="loginType" required>
                <option value="">-- Select Role --</option>
                <option value="ADMIN" <%= "ADMIN".equals(request.getAttribute("loginType")) ? "selected" : "" %>>Admin / Staff</option>
                <option value="FAMILY" <%= "FAMILY".equals(request.getAttribute("loginType")) ? "selected" : "" %>>Family Member</option>
            </select>
        </div>

        <button type="submit" class="btn-login" id="loginBtn" disabled>
            <span id="btnText">Sign In Securely</span>
        </button>
    </form>
</div>

<script>
    const form = document.getElementById('loginForm');
    const email = document.getElementById('email');
    const pass = document.getElementById('password');
    const type = document.getElementById('loginType');
    const btn = document.getElementById('loginBtn');
    const btnText = document.getElementById('btnText');

    function validate() {
        const isEmail = email.value.includes('@');
        const isPass = pass.value.length >= 1;
        const isType = type.value !== "";
        btn.disabled = !(isEmail && isPass && isType);
    }

    [email, pass, type].forEach(el => el.addEventListener('input', validate));

    form.onsubmit = () => {
        btn.disabled = true;
        btnText.innerText = "Verifying Credentials...";
    };
    
    // Initial check for browser autocomplete
    validate();
</script>

</body>
</html>