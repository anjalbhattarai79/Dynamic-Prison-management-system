<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% String path = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Request Visit | PMS Nepal</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy: #1a2744; --blue-acc: #3a6fd8; --cloud: #f4f6fb;
            --white: #ffffff; --border: #d0d9ee; --text-main: #1a2744;
            --text-sub: #5a7099; --radius: 12px;
        }
        body { font-family: 'DM Sans', sans-serif; background: var(--cloud); color: var(--text-main); margin: 0; padding: 40px; }
        .form-container { max-width: 600px; margin: 0 auto; background: var(--white); padding: 40px; border-radius: var(--radius); box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
        .header { margin-bottom: 30px; border-bottom: 1px solid var(--cloud); padding-bottom: 20px; }
        .header h1 { font-size: 24px; margin: 0; }
        .header p { color: var(--text-sub); font-size: 14px; margin-top: 5px; }
        
        .form-group { margin-bottom: 20px; }
        label { display: block; font-size: 14px; font-weight: 500; margin-bottom: 8px; }
        input, select, textarea {
            width: 100%; padding: 12px; border: 1px solid var(--border); border-radius: 8px;
            font-family: inherit; font-size: 14px; box-sizing: border-box;
        }
        input[readonly] { background: var(--cloud); cursor: not-allowed; }
        .btn-submit {
            background: var(--navy); color: white; border: none; padding: 14px 24px;
            border-radius: 8px; font-weight: 600; cursor: pointer; width: 100%; transition: 0.2s;
        }
        .btn-submit:hover { background: var(--blue-acc); }
        .back-link { display: block; text-align: center; margin-top: 20px; color: var(--text-sub); text-decoration: none; font-size: 14px; }
    </style>
</head>
<body>

<div class="form-container">
    <div class="header">
        <h1>New Visit Request</h1>
        <p>Schedule a visit for your family member.</p>
    </div>

    <form action="<%= path %>/family-request-visit" method="POST">
        <div class="form-group">
            <label>Visiting Prisoner</label>
            <input type="text" value="<%= request.getAttribute("prisonerName") %> (ID: <%= request.getAttribute("prisonerId") %>)" readonly>
        </div>

        <div class="form-group">
            <label for="visitDate">Preferred Visit Date</label>
            <input type="date" id="visitDate" name="visitDate" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
        </div>

        <div class="form-group">
            <label for="timeSlot">Time Slot</label>
            <select id="timeSlot" name="timeSlot" required>
                <option value="">Select a slot</option>
                <option value="MORNING">Morning (10:00 AM - 12:00 PM)</option>
                <option value="AFTERNOON">Afternoon (1:00 PM - 3:00 PM)</option>
                <option value="EVENING">Late Afternoon (3:00 PM - 5:00 PM)</option>
            </select>
        </div>

        <div class="form-group">
            <label for="purpose">Purpose of Visit</label>
            <textarea id="purpose" name="purpose" rows="3" placeholder="e.g., Personal / Delivering essentials"></textarea>
        </div>

        <button type="submit" class="btn-submit">Submit Request</button>
    </form>

    <a href="<%= path %>/family-dashboard" class="back-link">← Cancel and return to Dashboard</a>
</div>

</body>
</html>