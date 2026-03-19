<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.exam.model.*" %>
<%
  if (session.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
  User user = (User) session.getAttribute("user");
  List<Exam> exams = (List<Exam>) request.getAttribute("exams");
  String initials = user.getName().length() >= 2
    ? String.valueOf(user.getName().charAt(0)) + user.getName().split(" ")[user.getName().split(" ").length-1].charAt(0)
    : user.getName().substring(0,1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>ExamPortal — Select Exam</title>
  <link rel="stylesheet" href="css/style.css"/>
  <style>
    .exams-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1.25rem;
    }

    .exam-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 1.5rem;
      cursor: pointer;
      transition: var(--transition);
      text-decoration: none; color: inherit;
      display: flex; flex-direction: column; gap: 1rem;
      position: relative; overflow: hidden;
    }
    .exam-card::before {
      content: '';
      position: absolute; top: 0; left: 0; right: 0; height: 3px;
      background: linear-gradient(90deg, var(--accent), var(--accent2));
      transform: scaleX(0); transform-origin: left;
      transition: transform 0.3s ease;
    }
    .exam-card:hover {
      border-color: var(--border-hover);
      transform: translateY(-4px);
      box-shadow: 0 12px 40px rgba(0,0,0,0.4), var(--shadow-glow);
    }
    .exam-card:hover::before { transform: scaleX(1); }

    .exam-icon {
      width: 48px; height: 48px;
      background: linear-gradient(135deg, var(--accent-glow), var(--accent2-glow));
      border: 1px solid rgba(0,212,170,0.2);
      border-radius: var(--radius-sm);
      display: flex; align-items: center; justify-content: center;
      font-size: 22px;
    }

    .exam-title {
      font-family: var(--font-display);
      font-size: 1.05rem; font-weight: 700;
      color: var(--text-primary); margin-bottom: 4px;
    }

    .exam-subject {
      font-size: 12.5px; color: var(--text-secondary);
    }

    .exam-desc {
      font-size: 13px; color: var(--text-muted); line-height: 1.5;
    }

    .exam-meta {
      display: flex; gap: 10px; flex-wrap: wrap;
    }

    .meta-pill {
      display: flex; align-items: center; gap: 5px;
      background: var(--bg-card2); border: 1px solid var(--border);
      border-radius: 50px; padding: 4px 12px;
      font-size: 12px; color: var(--text-secondary);
    }

    .start-btn {
      margin-top: auto;
      display: flex; align-items: center; justify-content: space-between;
      background: linear-gradient(135deg, rgba(0,212,170,0.1), rgba(14,165,233,0.1));
      border: 1px solid rgba(0,212,170,0.2);
      border-radius: var(--radius-sm);
      padding: 10px 16px;
      font-size: 13px; font-weight: 600; color: var(--accent);
      transition: var(--transition);
    }
    .exam-card:hover .start-btn {
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      color: var(--bg-base); border-color: transparent;
    }

    .welcome-strip {
      background: linear-gradient(135deg, rgba(0,212,170,0.08), rgba(14,165,233,0.06));
      border: 1px solid rgba(0,212,170,0.15);
      border-radius: var(--radius-md);
      padding: 1.25rem 1.5rem;
      display: flex; align-items: center; gap: 16px;
      margin-bottom: 2rem;
    }

    .welcome-avatar {
      width: 44px; height: 44px; border-radius: 50%;
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      display: flex; align-items: center; justify-content: center;
      font-family: var(--font-display); font-size: 16px;
      font-weight: 800; color: var(--bg-base); flex-shrink: 0;
    }

    .empty-state {
      text-align: center; padding: 4rem 2rem;
      color: var(--text-secondary);
    }
    .empty-state .icon { font-size: 3rem; margin-bottom: 1rem; }
  </style>
</head>
<body>

  <nav class="navbar">
    <a href="ExamListServlet" class="navbar-brand">
      <div class="brand-icon">📋</div>
      ExamPortal
    </a>
    <div class="navbar-user">
      <div class="user-badge">
        <div class="user-avatar"><%= initials.toUpperCase() %></div>
        <%= user.getName() %>
      </div>
      <a href="LogoutServlet" class="btn btn-danger">Sign Out</a>
    </div>
  </nav>

  <div class="page-wrapper">

    <div class="welcome-strip anim-fade-up">
      <div class="welcome-avatar"><%= initials.toUpperCase() %></div>
      <div>
        <div style="font-weight:600; color:var(--text-primary)">Welcome back, <%= user.getName() %>!</div>
        <div style="font-size:13px; color:var(--text-secondary)">Roll No: <%= user.getRollNumber() %> &nbsp;·&nbsp; Choose an exam to begin</div>
      </div>
    </div>

    <div class="anim-fade-up anim-delay-1">
      <h1 class="page-title">Available Exams</h1>
      <p class="page-subtitle">Select an exam below to start. Make sure you have a stable connection before beginning.</p>
    </div>

    <% if (exams == null || exams.isEmpty()) { %>
      <div class="empty-state card anim-fade-up anim-delay-2">
        <div class="icon">📭</div>
        <p>No exams are available at the moment. Please check back later.</p>
      </div>
    <% } else { %>
    <div class="exams-grid">
      <%
        String[] icons = {"💻","🐍","🗄","📊","🔬","🧮","🌐","📐"};
        int i = 0;
        for (Exam exam : exams) {
          String icon = icons[i % icons.length]; i++;
      %>
      <a href="ExamServlet?examId=<%= exam.getId() %>" class="exam-card anim-fade-up anim-delay-<%= Math.min(i, 4) %>">
        <div style="display:flex; gap:12px; align-items:flex-start;">
          <div class="exam-icon"><%= icon %></div>
          <div>
            <div class="exam-title"><%= exam.getTitle() %></div>
            <div class="exam-subject"><%= exam.getSubject() %></div>
          </div>
        </div>

        <% if (exam.getDescription() != null && !exam.getDescription().isEmpty()) { %>
        <div class="exam-desc"><%= exam.getDescription() %></div>
        <% } %>

        <div class="exam-meta">
          <div class="meta-pill">⏱ <%= exam.getDurationMinutes() %> min</div>
          <div class="meta-pill">📝 <%= exam.getTotalMarks() %> marks</div>
          <span class="badge badge-green">Active</span>
        </div>

        <div class="start-btn">
          <span>Start Exam</span>
          <span>→</span>
        </div>
      </a>
      <% } %>
    </div>
    <% } %>

  </div>
</body>
</html>
