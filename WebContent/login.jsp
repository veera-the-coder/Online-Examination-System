<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>ExamPortal — Student Login</title>
  <link rel="stylesheet" href="css/style.css"/>
  <style>
    body { display: flex; align-items: center; justify-content: center; min-height: 100vh; }

    .login-wrap {
      position: relative; z-index: 1;
      width: 100%; max-width: 420px;
      padding: 1rem;
      animation: fadeUp 0.5s ease both;
    }

    .login-logo {
      text-align: center; margin-bottom: 2rem;
    }

    .login-logo .logo-icon {
      width: 60px; height: 60px;
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      border-radius: var(--radius-md);
      display: inline-flex; align-items: center; justify-content: center;
      font-size: 28px; margin-bottom: 1rem;
      animation: pulse-ring 2.5s ease infinite;
    }

    .login-logo h1 {
      font-family: var(--font-display);
      font-size: 1.8rem; font-weight: 800;
      color: var(--text-primary); letter-spacing: -0.5px;
    }

    .login-logo p {
      color: var(--text-secondary); font-size: 14px; margin-top: 4px;
    }

    .login-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 2rem 2rem 1.75rem;
      box-shadow: var(--shadow-card);
    }

    .login-card::after {
      content: '';
      position: absolute;
      top: -80px; right: -60px;
      width: 200px; height: 200px;
      background: radial-gradient(circle, rgba(0,212,170,0.08), transparent 70%);
      pointer-events: none;
    }

    .input-icon-wrap {
      position: relative;
    }

    .input-icon-wrap .icon {
      position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
      color: var(--text-muted); font-size: 15px; pointer-events: none;
    }

    .input-icon-wrap .form-control {
      padding-left: 40px;
    }

    .divider-text {
      display: flex; align-items: center; gap: 10px;
      color: var(--text-muted); font-size: 12px;
      margin: 1.25rem 0;
    }
    .divider-text::before, .divider-text::after {
      content: ''; flex: 1; height: 1px; background: var(--border);
    }

    .demo-creds {
      background: var(--bg-card2);
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      padding: 12px 14px;
      font-size: 12.5px;
      color: var(--text-secondary);
    }
    .demo-creds strong { color: var(--accent); font-weight: 600; }

    .orbs {
      position: fixed; inset: 0; pointer-events: none; z-index: 0; overflow: hidden;
    }
    .orb {
      position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.12;
    }
    .orb1 { width: 400px; height: 400px; background: var(--accent); top: -100px; right: -100px; }
    .orb2 { width: 300px; height: 300px; background: var(--accent2); bottom: -80px; left: -80px; }
  </style>
</head>
<body>
  <div class="orbs">
    <div class="orb orb1"></div>
    <div class="orb orb2"></div>
  </div>

  <div class="login-wrap">
    <div class="login-logo">
      <div class="logo-icon">📋</div>
      <h1>ExamPortal</h1>
      <p>Online Examination System</p>
    </div>

    <div class="login-card">
      <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
      %>
      <div class="alert alert-danger">
        <span>⚠</span> <%= error %>
      </div>
      <% } %>

      <form action="LoginServlet" method="post" id="loginForm">
        <div class="form-group">
          <label class="form-label">Roll Number</label>
          <div class="input-icon-wrap">
            <span class="icon">🎓</span>
            <input type="text" name="rollNumber" class="form-control"
                   placeholder="e.g. S001" required autocomplete="off"/>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Password</label>
          <div class="input-icon-wrap">
            <span class="icon">🔒</span>
            <input type="password" name="password" class="form-control"
                   placeholder="Enter your password" required/>
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-lg btn-block" id="loginBtn">
          <span id="btnText">Sign In</span>
          <span id="btnSpinner" style="display:none">⏳</span>
        </button>
      </form>

      <div class="divider-text">demo credentials</div>

      <div class="demo-creds">
        Roll Number: <strong>S001</strong> &nbsp;|&nbsp; Password: <strong>pass123</strong>
      </div>
    </div>
  </div>

  <script>
    document.getElementById('loginForm').addEventListener('submit', function() {
      document.getElementById('btnText').textContent = 'Signing in...';
      document.getElementById('btnSpinner').style.display = 'inline';
    });
  </script>
</body>
</html>
