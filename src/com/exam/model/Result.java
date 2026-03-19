package com.exam.model;

import java.sql.Timestamp;

public class Result {
    private int id, userId, examId, score, total;
    private String examTitle;
    private Timestamp attemptTime;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }
    public String getExamTitle() { return examTitle; }
    public void setExamTitle(String t) { this.examTitle = t; }
    public Timestamp getAttemptTime() { return attemptTime; }
    public void setAttemptTime(Timestamp t) { this.attemptTime = t; }

    public int getPercentage() {
        return total == 0 ? 0 : (score * 100) / total;
    }
}
