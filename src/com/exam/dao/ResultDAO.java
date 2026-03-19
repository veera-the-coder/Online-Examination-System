package com.exam.dao;

import com.exam.db.DBConnection;
import com.exam.model.Result;
import java.sql.*;
import java.util.*;

public class ResultDAO {

    public void saveResult(int userId, int examId, int score, int total) throws Exception {
        String sql = "INSERT INTO results (user_id, exam_id, score, total) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            ps.setInt(3, score);
            ps.setInt(4, total);
            ps.executeUpdate();
        }
    }

    public List<Result> getResultsByUser(int userId) throws Exception {
        List<Result> list = new ArrayList<>();
        String sql = "SELECT r.*, e.title AS exam_title FROM results r "
                   + "JOIN exams e ON r.exam_id = e.id "
                   + "WHERE r.user_id = ? ORDER BY r.attempt_time DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Result res = new Result();
                res.setId(rs.getInt("id"));
                res.setUserId(rs.getInt("user_id"));
                res.setExamId(rs.getInt("exam_id"));
                res.setScore(rs.getInt("score"));
                res.setTotal(rs.getInt("total"));
                res.setExamTitle(rs.getString("exam_title"));
                res.setAttemptTime(rs.getTimestamp("attempt_time"));
                list.add(res);
            }
        }
        return list;
    }
}
