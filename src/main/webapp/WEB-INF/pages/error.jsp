<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorTitle = (String) request.getAttribute("errorTitle");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String errorCode = (String) request.getAttribute("errorCode");
    
    if (errorTitle == null) errorTitle = "Something Went Wrong";
    if (errorMessage == null) errorMessage = "An unexpected error occurred.";
    if (errorCode == null) errorCode = "Error";
    
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= errorTitle %> | PMS Nepal</title>
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
            --shadow: 0 10px 40px rgba(26,39,68,0.08);
            --transition: .2s ease;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--cloud);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            color: var(--navy);
            padding: 20px;
        }

        .error-card {
            background: var(--white);
            width: 100%;
            max-width: 500px;
            padding: 60px 40px;
            border-radius: 12px;
            box-shadow: var(--shadow);
            border: 1px solid rgba(208, 217, 238, 0.5);
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .error-card::before {
            content: '';
            position: absolute;
            top: -50px;
            right: -50px;
            width: 150px;
            height: 150px;
            background: rgba(58,111,216,0.05);
            border-radius: 50%;
        }

        .logo-box {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            margin-bottom: 40px;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: var(--navy);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .logo-icon svg { width: 22px; height: 22px; stroke: white; fill: none; stroke-width: 2; }

        .logo-text h1 {
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            letter-spacing: -0.01em;
        }

        .illustration {
            margin-bottom: 24px;
            display: flex;
            justify-content: center;
        }

        .illustration svg {
            width: 80px;
            height: 80px;
            stroke: var(--blue-acc);
            fill: none;
            stroke-width: 1.5;
            opacity: 0.9;
        }

        .error-code {
            font-family: 'Playfair Display', serif;
            font-size: 80px;
            font-weight: 700;
            color: var(--navy);
            line-height: 1;
            margin-bottom: 16px;
            background: linear-gradient(135deg, var(--navy), var(--blue-acc));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .error-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 12px;
            color: var(--navy);
        }

        .error-message {
            font-size: 15px;
            color: var(--steel);
            line-height: 1.6;
            margin-bottom: 32px;
            max-width: 380px;
            margin-left: auto;
            margin-right: auto;
        }

        .actions {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 14px 28px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: all var(--transition);
            font-size: 15px;
            cursor: pointer;
            border: none;
            font-family: inherit;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--navy), var(--navy-mid));
            color: white;
            box-shadow: 0 4px 12px rgba(26, 39, 68, 0.2);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(26, 39, 68, 0.25);
        }

        .btn-secondary {
            background-color: transparent;
            color: var(--navy);
            border: 1px solid var(--border);
        }

        .btn-secondary:hover {
            background-color: var(--cloud);
        }

        /* Responsive */
        @media (max-width: 480px) {
            .error-card { padding: 40px 24px; }
            .error-code { font-size: 60px; }
        }
    </style>
</head>
<body>

    <div class="error-card">
        <div class="logo-box">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <div class="logo-text">
                <h1>PMS Nepal</h1>
            </div>
        </div>

        <div class="illustration">
            <% if ("404".equals(errorCode)) { %>
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
            <% } else { %>
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <% } %>
        </div>
        
        <div class="error-code"><%= errorCode %></div>
        <h1 class="error-title"><%= errorTitle %></h1>
        <p class="error-message"><%= errorMessage %></p>
        
        <div class="actions">
            <a href="<%= contextPath %>/" class="btn btn-primary">
                <svg style="width:18px;height:18px" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                Return to Security Portal
            </a>
            <button onclick="window.history.back()" class="btn btn-secondary">
                <svg style="width:18px;height:18px" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                Go Back to Previous
            </button>
        </div>
    </div>

</body>
</html>
