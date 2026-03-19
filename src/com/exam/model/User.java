package com.exam.model;

public class User {
    private int id;
    private String rollNumber, name, password, email;

    public User() {}
    public User(int id, String rollNumber, String name, String email) {
        this.id = id; this.rollNumber = rollNumber;
        this.name = name; this.email = email;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
