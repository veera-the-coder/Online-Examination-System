package com.exam.servlet;

import com.exam.dao.UserDAO;
import com.exam.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String roll = req.getParameter("rollNumber");
        String pass = req.getParameter("password");
        try {
            UserDAO dao = new UserDAO();
            User user = dao.login(roll, pass);
            if (user != null) {
                HttpSession session = req.getSession();
                session.setAttribute("user", user);
                res.sendRedirect("ExamListServlet");
            } else {
                req.setAttribute("error", "Invalid Roll Number or Password. Please try again.");
                req.getRequestDispatcher("login.jsp").forward(req, res);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("login.jsp").forward(req, res);
    }
}
