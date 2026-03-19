package com.exam.dao;

import com.exam.db.DBConnection;
import com.exam.model.User;
import java.sql.*;

public class UserDAO {

    public User login(String rollNumber, String password) throws Exception {
        String sql = "SELECT * FROM users WHERE roll_number = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, rollNumber);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setName(rs.getString("name"));
                u.setRollNumber(rs.getString("roll_number"));
                u.setEmail(rs.getString("email"));
                return u;
            }
        }
        return null;
    }
}
