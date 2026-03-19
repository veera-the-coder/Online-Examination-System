package com.exam.model;

public class Exam {
    private int id, durationMinutes, totalMarks;
    private String title, subject, description;
    private boolean isActive;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int d) { this.durationMinutes = d; }
    public int getTotalMarks() { return totalMarks; }
    public void setTotalMarks(int t) { this.totalMarks = t; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getDescription() { return description; }
    public void setDescription(String d) { this.description = d; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean a) { this.isActive = a; }
}
