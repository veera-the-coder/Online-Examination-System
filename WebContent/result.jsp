<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, com.exam.model.*" %>
<%
  if (session.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
  User user = (User) session.getAttribute("user");
  int score = (Integer) request.getAttribute("score");
  int total = (Integer) request.getAttribute("total");
  Exam exam  = (Exam)  request.getAttribute("exam");
  List<Question> questions = (List<Question>) request.getAttribute("questions");
  Map<Integer, String>  submitted  = (Map<Integer,String>)  request.getAttribute("submitted");
  Map<Integer, Boolean> correctMap = (Map<Integer,Boolean>) request.getAttribute("correctMap");

  int pct = total > 0 ? (score * 100) / total : 0;
  boolean passed = pct >= 40;
  int wrong = 0, unanswered = 0;
  for (Question q : questions) {
    String ans = submitted.get(q.getId());
    if (ans == null || ans.isEmpty()) unanswered++;
    else if (!correctMap.get(q.getId())) wrong++;
  }
  int correct = score; // since each q = 1 mark; adjust if marks vary

  String initials = user.getName().length() >= 2
    ? String.valueOf(user.getName().charAt(0)) + user.getName().split(" ")[user.getName().split(" ").length-1].charAt(0)
    : user.getName().substring(0,1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>ExamPortal — Results</title>
  <link rel="stylesheet" href="css/style.css"/>
  <style>
    .result-hero {
      text-align: center;
      padding: 2.5rem 2rem;
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      margin-bottom: 1.5rem;
      position: relative; overflow: hidden;
    }

    .result-hero::before {
      content: '';
      position: absolute; inset: 0;
      background: radial-gradient(ellipse at 50% 0%,
        <%= passed ? "rgba(52,211,153,0.08)" : "rgba(248,113,113,0.07)" %>, transparent 60%);
    }

    .score-ring {
      position: relative; display: inline-block;
      width: 160px; height: 160px; margin: 0 auto 1.5rem;
    }

    .score-ring svg { transform: rotate(-90deg); }

    .score-text {
      position: absolute; inset: 0;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
    }

    .score-number {
      font-family: var(--font-display);
      font-size: 2.4rem; font-weight: 800;
      color: var(--text-primary); line-height: 1;
    }

    .score-pct {
      font-size: 13px; color: var(--text-secondary); margin-top: 2px;
    }

    .result-status {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 8px 24px; border-radius: 50px;
      font-family: var(--font-display); font-size: 1rem; font-weight: 700;
      margin-bottom: 1rem;
      <%= passed
        ? "background:rgba(52,211,153,0.15); border:1px solid rgba(52,211,153,0.3); color:var(--success);"
        : "background:rgba(248,113,113,0.12); border:1px solid rgba(248,113,113,0.3); color:var(--danger);" %>
    }

    .result-exam-name {
      font-family: var(--font-display);
      font-size: 1.5rem; font-weight: 800;
      color: var(--text-primary); margin-bottom: 6px;
    }

    .breakdown-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .bk-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-md);
      padding: 1.1rem;
      text-align: center;
    }

    .bk-icon { font-size: 1.5rem; margin-bottom: 6px; }
    .bk-value {
      font-family: var(--font-display);
      font-size: 1.6rem; font-weight: 800; line-height: 1;
    }
    .bk-label { font-size: 11px; color: var(--text-muted);
      text-transform: uppercase; letter-spacing: 0.6px; margin-top: 4px; }

    /* Review section */
    .review-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 1.5rem 1.75rem;
      margin-bottom: 1rem;
      position: relative;
    }

    .review-card.correct-card { border-left: 3px solid var(--success); }
    .review-card.wrong-card   { border-left: 3px solid var(--danger);  }
    .review-card.skip-card    { border-left: 3px solid var(--text-muted); }

    .review-q-num { font-size: 11px; font-weight: 600;
      text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 8px; }
    .review-q-num.correct-card { color: var(--success); }
    .review-q-num.wrong-card   { color: var(--danger); }
    .review-q-num.skip-card    { color: var(--text-muted); }

    .review-q-text { font-size: 15px; font-weight: 500;
      color: var(--text-primary); margin-bottom: 1rem; line-height: 1.5; }

    .review-opts { display: flex; flex-direction: column; gap: 7px; }

    .review-opt {
      display: flex; align-items: center; gap: 12px;
      padding: 9px 14px; border-radius: var(--radius-sm);
      font-size: 13.5px; color: var(--text-secondary);
      border: 1px solid transparent;
    }

    .review-opt.is-correct {
      background: var(--success-bg);
      border-color: rgba(52,211,153,0.25);
      color: var(--success);
    }
    .review-opt.is-wrong {
      background: var(--danger-bg);
      border-color: rgba(248,113,113,0.25);
      color: var(--danger);
    }

    .opt-tag {
      width: 24px; height: 24px; flex-shrink: 0;
      border-radius: 50%; display: flex; align-items: center;
      justify-content: center; font-size: 10px; font-weight: 700;
      background: var(--bg-card2); color: var(--text-muted);
    }
    .is-correct .opt-tag { background: var(--success); color: var(--bg-base); }
    .is-wrong .opt-tag   { background: var(--danger);  color: #fff; }

    .result-actions {
      display: flex; gap: 12px; justify-content: center;
      flex-wrap: wrap; margin-top: 1rem;
    }

    /* Confetti dots */
    .confetti-wrap {
      position: fixed; inset: 0; pointer-events: none; z-index: 0; overflow: hidden;
    }
    .confetti-dot {
      position: absolute; width: 8px; height: 8px; border-radius: 2px;
      animation: confettiFall linear forwards;
    }
    @keyframes confettiFall {
      0%   { transform: translateY(-20px) rotate(0deg); opacity: 1; }
      100% { transform: translateY(100vh) rotate(720deg); opacity: 0; }
    }
  </style>
</head>
<body>

  <% if (passed) { %>
  <div class="confetti-wrap" id="confetti"></div>
  <% } %>

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

    <!-- Hero result card -->
    <div class="result-hero anim-fade-up">
      <div class="score-ring">
        <svg width="160" height="160" viewBox="0 0 160 160">
          <circle cx="80" cy="80" r="68" fill="none"
            stroke="<%= passed ? "rgba(52,211,153,0.15)" : "rgba(248,113,113,0.12)" %>"
            stroke-width="12"/>
          <circle cx="80" cy="80" r="68" fill="none"
            stroke="<%= passed ? "var(--success)" : "var(--danger)" %>"
            stroke-width="12" stroke-linecap="round"
            stroke-dasharray="427"
            stroke-dashoffset="<%= Math.round(427 - (427.0 * pct / 100)) %>"
            id="scoreArc"/>
        </svg>
        <div class="score-text">
          <div class="score-number"><%= score %>/<%= total %></div>
          <div class="score-pct"><%= pct %>%</div>
        </div>
      </div>

      <div class="result-status">
        <%= passed ? "✅ PASSED" : "❌ FAILED" %>
      </div>

      <div class="result-exam-name"><%= exam.getTitle() %></div>
      <div style="color:var(--text-secondary); font-size:14px;">
        <%= user.getName() %> &nbsp;·&nbsp; Roll No: <%= user.getRollNumber() %>
      </div>
    </div>

    <!-- Breakdown stats -->
    <div class="breakdown-grid anim-fade-up anim-delay-1">
      <div class="bk-card">
        <div class="bk-icon">✅</div>
        <div class="bk-value" style="color:var(--success);"><%= score %></div>
        <div class="bk-label">Correct</div>
      </div>
      <div class="bk-card">
        <div class="bk-icon">❌</div>
        <div class="bk-value" style="color:var(--danger);"><%= wrong %></div>
        <div class="bk-label">Wrong</div>
      </div>
      <div class="bk-card">
        <div class="bk-icon">⏭</div>
        <div class="bk-value" style="color:var(--text-muted);"><%= unanswered %></div>
        <div class="bk-label">Skipped</div>
      </div>
      <div class="bk-card">
        <div class="bk-icon">🎯</div>
        <div class="bk-value" style="color:var(--accent2);"><%= pct %>%</div>
        <div class="bk-label">Score</div>
      </div>
      <div class="bk-card">
        <div class="bk-icon">📝</div>
        <div class="bk-value"><%= questions.size() %></div>
        <div class="bk-label">Total Q</div>
      </div>
    </div>

    <!-- Answer Review -->
    <div class="anim-fade-up anim-delay-2">
      <h2 class="page-title" style="font-size:1.4rem; margin-bottom:0.3rem;">Answer Review</h2>
      <p class="page-subtitle">Detailed breakdown of every question</p>
    </div>

    <%
      int rn = 1;
      for (Question q : questions) {
        String ans = submitted.get(q.getId());
        boolean isCorrect = correctMap.get(q.getId());
        boolean skipped   = (ans == null || ans.isEmpty());
        String cardClass  = skipped ? "skip-card" : (isCorrect ? "correct-card" : "wrong-card");
        String rnLabel    = skipped ? "Skipped" : (isCorrect ? "Correct" : "Wrong");
        String[] opts    = {q.getOptionA(), q.getOptionB(), q.getOptionC(), q.getOptionD()};
        String[] labels  = {"A","B","C","D"};
    %>
    <div class="review-card <%= cardClass %> anim-fade-up" style="animation-delay:<%= Math.min(rn * 0.03, 0.5) %>s">
      <div class="review-q-num <%= cardClass %>">
        Q<%= rn++ %> &nbsp;·&nbsp; <%= rnLabel %>
        <% if (!skipped) { %> &nbsp;·&nbsp; Your answer: <strong><%= ans %></strong><% } %>
        &nbsp;·&nbsp; Correct: <strong><%= q.getCorrectOption() %></strong>
      </div>
      <div class="review-q-text"><%= q.getQuestionText() %></div>
      <div class="review-opts">
        <% for (int oi=0; oi<4; oi++) {
             if (opts[oi] == null || opts[oi].isEmpty()) continue;
             boolean isThisCorrect = labels[oi].equals(q.getCorrectOption());
             boolean isThisChosen  = labels[oi].equals(ans);
             String optClass = isThisCorrect ? "is-correct" : (isThisChosen && !isThisCorrect ? "is-wrong" : "");
        %>
        <div class="review-opt <%= optClass %>">
          <div class="opt-tag"><%= labels[oi] %></div>
          <span><%= opts[oi] %></span>
          <% if (isThisCorrect) { %><span style="margin-left:auto; font-size:12px;">✓ Correct</span><% } %>
          <% if (isThisChosen && !isThisCorrect) { %><span style="margin-left:auto; font-size:12px;">✗ Your answer</span><% } %>
        </div>
        <% } %>
      </div>
    </div>
    <% } %>

    <div class="result-actions anim-fade-up">
      <a href="ExamListServlet" class="btn btn-primary btn-lg">← Back to Exams</a>
      <a href="LogoutServlet"   class="btn btn-outline">Sign Out</a>
    </div>

  </div>

  <script>
    <% if (passed) { %>
    // Confetti burst on pass
    const colors = ['#00d4aa','#0ea5e9','#34d399','#fbbf24','#f472b6'];
    const wrap = document.getElementById('confetti');
    for (let i = 0; i < 60; i++) {
      const dot = document.createElement('div');
      dot.className = 'confetti-dot';
      dot.style.cssText = [
        'left:' + Math.random() * 100 + 'vw',
        'background:' + colors[Math.floor(Math.random() * colors.length)],
        'animation-duration:' + (1.5 + Math.random() * 2) + 's',
        'animation-delay:' + (Math.random() * 0.8) + 's',
        'width:' + (6 + Math.random() * 6) + 'px',
        'height:' + (6 + Math.random() * 6) + 'px'
      ].join(';');
      wrap.appendChild(dot);
    }
    setTimeout(() => wrap.remove(), 4000);
    <% } %>

    // Animate arc on load
    const arc = document.getElementById('scoreArc');
    if (arc) {
      const target = parseInt(arc.getAttribute('stroke-dashoffset'));
      arc.style.strokeDashoffset = '427';
      arc.style.transition = 'stroke-dashoffset 1.2s cubic-bezier(0.4,0,0.2,1) 0.3s';
      setTimeout(() => arc.style.strokeDashoffset = target, 50);
    }
  </script>
</body>
</html>
