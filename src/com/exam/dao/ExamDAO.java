package com.exam.dao;

import com.exam.db.DBConnection;
import com.exam.model.Exam;
import java.sql.*;
import java.util.*;

public class ExamDAO {

    public List<Exam> getAllActiveExams() throws Exception {
        List<Exam> list = new ArrayList<>();
        String sql = "SELECT * FROM exams WHERE is_active = 1 ORDER BY title";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapExam(rs));
            }
        }
        return list;
    }

    public Exam getById(int id) throws Exception {
        String sql = "SELECT * FROM exams WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapExam(rs);
        }
        return null;
    }

    private Exam mapExam(ResultSet rs) throws SQLException {
        Exam e = new Exam();
        e.setId(rs.getInt("id"));
        e.setTitle(rs.getString("title"));
        e.setSubject(rs.getString("subject"));
        e.setDurationMinutes(rs.getInt("duration_minutes"));
        e.setTotalMarks(rs.getInt("total_marks"));
        e.setDescription(rs.getString("description"));
        e.setActive(rs.getInt("is_active") == 1);
        return e;
    }
}
