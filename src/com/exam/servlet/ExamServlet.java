package com.exam.servlet;

import com.exam.dao.*;
import com.exam.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/ExamServlet")
public class ExamServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }
        try {
            int examId = Integer.parseInt(req.getParameter("examId"));
            ExamDAO examDao = new ExamDAO();
            QuestionDAO qDao = new QuestionDAO();
            Exam exam = examDao.getById(examId);
            req.setAttribute("exam", exam);
            req.setAttribute("questions", qDao.getByExam(examId));
            req.getRequestDispatcher("exam.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
