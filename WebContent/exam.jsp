<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.exam.model.*" %>
<%
  if (session.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
  User user = (User) session.getAttribute("user");
  Exam exam = (Exam) request.getAttribute("exam");
  List<Question> questions = (List<Question>) request.getAttribute("questions");
  if (exam == null) { response.sendRedirect("ExamListServlet"); return; }
  int totalSeconds = exam.getDurationMinutes() * 60;
  String initials = user.getName().length() >= 2
    ? String.valueOf(user.getName().charAt(0)) + user.getName().split(" ")[user.getName().split(" ").length-1].charAt(0)
    : user.getName().substring(0,1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>ExamPortal — <%= exam.getTitle() %></title>
  <link rel="stylesheet" href="css/style.css"/>
  <style>
    .exam-layout {
      display: grid;
      grid-template-columns: 1fr 300px;
      gap: 1.5rem;
      align-items: start;
    }
    @media (max-width: 768px) {
      .exam-layout { grid-template-columns: 1fr; }
      .exam-sidebar { order: -1; }
    }

    /* ── Sidebar ── */
    .exam-sidebar { position: sticky; top: 80px; }

    .timer-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 1.5rem;
      text-align: center;
      margin-bottom: 1rem;
    }

    .timer-display {
      font-family: var(--font-display);
      font-size: 2.8rem; font-weight: 800;
      letter-spacing: 2px;
      color: var(--accent);
      transition: color 0.3s;
    }
    .timer-display.warning { color: var(--warning); }
    .timer-display.danger  { color: var(--danger); animation: pulse-ring 1s ease infinite; }

    .timer-label {
      font-size: 11px; text-transform: uppercase;
      letter-spacing: 1px; color: var(--text-muted);
      margin-top: 4px;
    }

    .q-nav-grid {
      display: grid; grid-template-columns: repeat(5, 1fr); gap: 6px;
    }

    .q-dot {
      aspect-ratio: 1; border-radius: var(--radius-sm);
      background: var(--bg-card2); border: 1px solid var(--border);
      display: flex; align-items: center; justify-content: center;
      font-size: 11px; font-weight: 600; color: var(--text-muted);
      cursor: pointer; transition: var(--transition);
    }
    .q-dot.answered {
      background: rgba(0,212,170,0.15); border-color: rgba(0,212,170,0.4);
      color: var(--accent);
    }
    .q-dot.current {
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      color: var(--bg-base); border-color: transparent;
    }

    /* ── Questions ── */
    .question-block {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 1.75rem 2rem;
      margin-bottom: 1.25rem;
      transition: var(--transition);
    }
    .question-block:hover { border-color: rgba(255,255,255,0.1); }

    .q-number {
      display: inline-flex; align-items: center;
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      color: var(--bg-base); font-weight: 800; font-size: 11px;
      border-radius: 50px; padding: 3px 12px; margin-bottom: 12px;
      font-family: var(--font-display);
    }

    .q-marks {
      float: right;
      background: var(--bg-card2); border: 1px solid var(--border);
      border-radius: 50px; padding: 3px 10px;
      font-size: 11px; color: var(--text-secondary);
    }

    .q-text {
      font-size: 15.5px; font-weight: 500;
      color: var(--text-primary); line-height: 1.6;
      margin-bottom: 1.25rem; clear: both;
    }

    .options-list { display: flex; flex-direction: column; gap: 10px; }

    .option-label {
      display: flex; align-items: center; gap: 14px;
      background: var(--bg-card2); border: 1px solid var(--border);
      border-radius: var(--radius-md);
      padding: 13px 16px; cursor: pointer;
      transition: var(--transition);
      font-size: 14.5px; color: var(--text-secondary);
    }
    .option-label:hover {
      border-color: rgba(0,212,170,0.35);
      color: var(--text-primary);
      background: rgba(0,212,170,0.05);
    }

    .option-label input[type="radio"] { display: none; }

    .option-circle {
      width: 28px; height: 28px; flex-shrink: 0;
      border: 2px solid var(--text-muted); border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 11px; font-weight: 700; color: var(--text-muted);
      transition: var(--transition);
    }

    .option-label input:checked ~ .option-circle,
    .option-label.selected .option-circle {
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      border-color: transparent; color: var(--bg-base);
    }

    .option-label:has(input:checked) {
      border-color: var(--accent);
      background: rgba(0,212,170,0.08);
      color: var(--text-primary);
    }

    /* progress bar in header */
    .exam-progress-bar {
      height: 3px; background: var(--bg-card2);
      position: fixed; top: 64px; left: 0; right: 0; z-index: 99;
    }
    .exam-progress-fill {
      height: 100%;
      background: linear-gradient(90deg, var(--accent), var(--accent2));
      transition: width 0.3s ease;
    }

    /* confirm modal */
    .modal-overlay {
      display: none; position: fixed; inset: 0; z-index: 200;
      background: rgba(0,0,0,0.7); backdrop-filter: blur(4px);
      align-items: center; justify-content: center;
    }
    .modal-overlay.active { display: flex; }
    .modal-box {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: var(--radius-lg); padding: 2rem;
      max-width: 380px; width: 90%; text-align: center;
      animation: fadeUp 0.3s ease both;
    }
    .modal-icon { font-size: 3rem; margin-bottom: 1rem; }
    .modal-title {
      font-family: var(--font-display); font-size: 1.25rem;
      font-weight: 700; margin-bottom: 8px;
    }
    .modal-body { color: var(--text-secondary); font-size: 14px; margin-bottom: 1.5rem; }
    .modal-actions { display: flex; gap: 10px; justify-content: center; }
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
    </div>
  </nav>

  <!-- thin progress bar -->
  <div class="exam-progress-bar">
    <div class="exam-progress-fill" id="progressFill" style="width:0%"></div>
  </div>

  <div class="page-wrapper" style="max-width:1000px;">

    <div class="anim-fade-up" style="margin-bottom:1.75rem;">
      <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom:8px;">
        <h1 class="page-title" style="margin:0;"><%= exam.getTitle() %></h1>
        <span class="badge badge-blue"><%= exam.getSubject() %></span>
      </div>
      <div style="display:flex; gap:16px; color:var(--text-muted); font-size:13px;">
        <span>📝 <%= questions.size() %> Questions</span>
        <span>🏆 <%= exam.getTotalMarks() %> Marks</span>
        <span>⏱ <%= exam.getDurationMinutes() %> Minutes</span>
      </div>
    </div>

    <form action="SubmitServlet" method="post" id="examForm">
      <input type="hidden" name="examId" value="<%= exam.getId() %>"/>

      <div class="exam-layout">

        <!-- Questions -->
        <div id="questionsArea">
          <%
            int qNum = 1;
            for (Question q : questions) {
          %>
          <div class="question-block anim-fade-up" id="qblock-<%= qNum %>"
               style="animation-delay:<%= Math.min(qNum * 0.04, 0.4) %>s">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
              <span class="q-number">Question <%= qNum %></span>
              <span class="q-marks"><%= q.getMarks() %> mark<%= q.getMarks()>1?"s":"" %></span>
            </div>
            <div class="q-text"><%= q.getQuestionText() %></div>
            <div class="options-list">
              <% String[] opts = {q.getOptionA(), q.getOptionB(), q.getOptionC(), q.getOptionD()};
                 String[] labels = {"A","B","C","D"};
                 for (int oi=0; oi<4; oi++) {
                   if (opts[oi] == null || opts[oi].isEmpty()) continue;
              %>
              <label class="option-label" onclick="markAnswered(<%= qNum %>, this)">
                <input type="radio" name="q_<%= q.getId() %>" value="<%= labels[oi] %>"/>
                <div class="option-circle"><%= labels[oi] %></div>
                <span><%= opts[oi] %></span>
              </label>
              <% } %>
            </div>
          </div>
          <% qNum++; } %>
        </div>

        <!-- Sidebar -->
        <aside class="exam-sidebar">
          <div class="timer-card anim-fade-up anim-delay-1">
            <div class="timer-display" id="timer">--:--</div>
            <div class="timer-label">Time Remaining</div>
            <hr class="divider" style="margin:1rem 0 0.75rem;"/>
            <div style="font-size:12px; color:var(--text-muted);">
              Answered: <strong id="answeredCount" style="color:var(--accent);">0</strong>
              / <%= questions.size() %>
            </div>
            <div class="progress-wrap" style="margin-top:8px;">
              <div class="progress-fill" id="answerProgress" style="width:0%"></div>
            </div>
          </div>

          <div class="card anim-fade-up anim-delay-2" style="padding:1.25rem; margin-bottom:1rem;">
            <div style="font-size:11px; color:var(--text-muted); text-transform:uppercase;
                 letter-spacing:0.8px; margin-bottom:10px;">Question Navigator</div>
            <div class="q-nav-grid" id="qNavGrid">
              <% for (int n=1; n<=questions.size(); n++) { %>
              <div class="q-dot" id="qdot-<%= n %>"
                   onclick="document.getElementById('qblock-<%= n %>').scrollIntoView({behavior:'smooth', block:'center'})">
                <%= n %>
              </div>
              <% } %>
            </div>
          </div>

          <button type="button" onclick="showConfirm()" class="btn btn-primary btn-block btn-lg">
            Submit Exam →
          </button>

          <div style="font-size:11.5px; color:var(--text-muted); text-align:center; margin-top:10px;">
            Exam will auto-submit when time runs out
          </div>
        </aside>
      </div>
    </form>
  </div>

  <!-- Confirm Modal -->
  <div class="modal-overlay" id="confirmModal">
    <div class="modal-box">
      <div class="modal-icon">📤</div>
      <div class="modal-title">Submit Exam?</div>
      <div class="modal-body" id="confirmMsg">Are you sure you want to submit?</div>
      <div class="modal-actions">
        <button class="btn btn-outline" onclick="hideConfirm()">Cancel</button>
        <button class="btn btn-primary" onclick="submitExam()">Yes, Submit</button>
      </div>
    </div>
  </div>

  <script>
    const TOTAL = <%= totalSeconds %>;
    const TOTAL_Q = <%= questions.size() %>;
    let remaining = TOTAL;
    let answered = new Set();

    function pad(n) { return n.toString().padStart(2,'0'); }

    const timerEl = document.getElementById('timer');
    const interval = setInterval(() => {
      remaining--;
      const m = Math.floor(remaining / 60);
      const s = remaining % 60;
      timerEl.textContent = pad(m) + ':' + pad(s);
      timerEl.className = 'timer-display'
        + (remaining < 300 ? ' warning' : '')
        + (remaining < 60  ? ' danger'  : '');
      if (remaining <= 0) { clearInterval(interval); submitExam(); }
    }, 1000);
    timerEl.textContent = pad(Math.floor(TOTAL/60)) + ':' + pad(TOTAL%60);

    function markAnswered(qNum, labelEl) {
      answered.add(qNum);
      document.getElementById('qdot-' + qNum).className = 'q-dot answered';
      document.getElementById('answeredCount').textContent = answered.size;
      document.getElementById('answerProgress').style.width =
        Math.round((answered.size / TOTAL_Q) * 100) + '%';
    }

    function showConfirm() {
      const left = TOTAL_Q - answered.size;
      document.getElementById('confirmMsg').textContent =
        answered.size + ' of ' + TOTAL_Q + ' answered. '
        + (left > 0 ? left + ' question(s) unanswered. ' : '')
        + 'Are you sure you want to submit?';
      document.getElementById('confirmModal').classList.add('active');
    }

    function hideConfirm() {
      document.getElementById('confirmModal').classList.remove('active');
    }

    function submitExam() {
      clearInterval(interval);
      document.getElementById('examForm').submit();
    }

    // Scroll spy for navigator
    const observer = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          const id = e.target.id.replace('qblock-','');
          document.querySelectorAll('.q-dot').forEach(d => d.classList.remove('current'));
          const dot = document.getElementById('qdot-' + id);
          if (dot && !dot.classList.contains('answered'))
            dot.classList.add('current');
        }
      });
    }, { threshold: 0.5 });

    document.querySelectorAll('.question-block').forEach(b => observer.observe(b));

    // Prevent accidental back navigation
    history.pushState(null, null, location.href);
    window.onpopstate = function() { history.pushState(null, null, location.href); };
  </script>
</body>
</html>
