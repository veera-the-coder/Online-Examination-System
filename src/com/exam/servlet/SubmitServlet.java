package com.exam.servlet;

import com.exam.dao.*;
import com.exam.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.*;

@WebServlet("/SubmitServlet")
public class SubmitServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        try {
            int examId = Integer.parseInt(req.getParameter("examId"));
            ExamDAO examDao = new ExamDAO();
            QuestionDAO qDao = new QuestionDAO();
            Exam exam = examDao.getById(examId);
            List<Question> questions = qDao.getByExam(examId);

            int score = 0, total = 0;
            Map<Integer, String> submitted = new HashMap<>();
            Map<Integer, Boolean> correctMap = new HashMap<>();

            for (Question q : questions) {
                total += q.getMarks();
                String ans = req.getParameter("q_" + q.getId());
                submitted.put(q.getId(), ans);
                if (ans != null && ans.equalsIgnoreCase(q.getCorrectOption())) {
                    score += q.getMarks();
                    correctMap.put(q.getId(), true);
                } else {
                    correctMap.put(q.getId(), false);
                }
            }

            ResultDAO rDao = new ResultDAO();
            rDao.saveResult(user.getId(), examId, score, total);

            req.setAttribute("score", score);
            req.setAttribute("total", total);
            req.setAttribute("exam", exam);
            req.setAttribute("questions", questions);
            req.setAttribute("submitted", submitted);
            req.setAttribute("correctMap", correctMap);
            req.getRequestDispatcher("result.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
