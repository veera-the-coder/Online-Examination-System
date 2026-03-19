#!/bin/bash
# ============================================================
#  Online Examination System - Ubuntu Setup Script
#  Run with: chmod +x setup_ubuntu.sh && sudo ./setup_ubuntu.sh
# ============================================================

echo "================================================"
echo "  Online Exam System - Ubuntu Installation"
echo "================================================"

# Update system
echo "[1/6] Updating system packages..."
apt-get update -y && apt-get upgrade -y

# Install Java JDK 11
echo "[2/6] Installing Java JDK 11..."
apt-get install -y openjdk-11-jdk
java -version

# Install Apache Tomcat 10
echo "[3/6] Installing Apache Tomcat 10..."
apt-get install -y tomcat10 tomcat10-admin
systemctl start tomcat10
systemctl enable tomcat10

# Install MySQL Server
echo "[4/6] Installing MySQL Server..."
apt-get install -y mysql-server
systemctl start mysql
systemctl enable mysql

# Secure MySQL and create database
echo "[5/6] Setting up MySQL database..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'exam@2024';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS online_exam;
USE online_exam;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  roll_number VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS exams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  subject VARCHAR(100),
  duration_minutes INT NOT NULL DEFAULT 30,
  total_marks INT NOT NULL,
  description TEXT,
  is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE IF NOT EXISTS questions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exam_id INT NOT NULL,
  question_text TEXT NOT NULL,
  option_a VARCHAR(300),
  option_b VARCHAR(300),
  option_c VARCHAR(300),
  option_d VARCHAR(300),
  correct_option CHAR(1) NOT NULL,
  marks INT DEFAULT 1,
  FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  exam_id INT NOT NULL,
  score INT NOT NULL,
  total INT NOT NULL,
  attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (exam_id) REFERENCES exams(id)
);

-- Sample Data
INSERT IGNORE INTO users VALUES 
  (1,'S001','Arjun Sharma','pass123','arjun@example.com',NOW()),
  (2,'S002','Priya Patel','pass123','priya@example.com',NOW()),
  (3,'S003','Rahul Kumar','pass123','rahul@example.com',NOW());

INSERT IGNORE INTO exams VALUES 
  (1,'Java Programming Fundamentals','Computer Science',30,10,'Test your Java basics knowledge',1),
  (2,'Python Essentials','Computer Science',25,8,'Core Python programming concepts',1),
  (3,'Database Management','Information Technology',20,6,'SQL and database fundamentals',1);

INSERT IGNORE INTO questions VALUES
  (1,1,'Which keyword is used to create an object in Java?','class','new','object','create','B',1),
  (2,1,'What is the default value of an int variable in Java?','null','0','undefined','-1','B',1),
  (3,1,'Which of these is NOT a Java primitive type?','int','String','float','char','B',1),
  (4,1,'What does JVM stand for?','Java Virtual Machine','Java Variable Method','Java Verified Module','Just Virtual Machine','A',1),
  (5,1,'Which method is the entry point of a Java program?','start()','run()','main()','init()','C',1),
  (6,1,'What is the size of int in Java?','2 bytes','4 bytes','8 bytes','16 bytes','B',1),
  (7,1,'Which operator is used for inheritance in Java?','implements','inherits','extends','super','C',1),
  (8,1,'What does OOP stand for?','Object Oriented Programming','Object Operating Process','Optional Object Protocol','Output Oriented Procedure','A',1),
  (9,1,'Which collection does NOT allow duplicates?','ArrayList','LinkedList','Set','Vector','C',1),
  (10,1,'What is used to handle exceptions in Java?','try-catch','if-else','switch','loop','A',1),
  (11,2,'Which symbol is used for single line comments in Python?','//','#','/*','--','B',1),
  (12,2,'What is the correct way to create a list in Python?','list = ()','list = {}','list = []','list = <>','C',1),
  (13,2,'Which function is used to get the length of a list?','size()','count()','len()','length()','C',1),
  (14,2,'What is the output of print(type(3.14))?','int','str','float','double','C',1),
  (15,2,'Which keyword defines a function in Python?','function','def','fun','method','B',1),
  (16,2,'What is the result of 10 // 3 in Python?','3.33','3','4','1','B',1),
  (17,2,'Which data type is immutable in Python?','list','dict','set','tuple','D',1),
  (18,2,'What does pip stand for?','Python Install Package','Pip Installs Packages','Package Install Python','Python Index Package','B',1),
  (19,3,'What does SQL stand for?','Structured Query Language','Simple Query Language','Structured Question Logic','Sequential Query List','A',1),
  (20,3,'Which SQL command retrieves data?','INSERT','UPDATE','SELECT','DELETE','C',1),
  (21,3,'Which SQL constraint ensures unique values?','PRIMARY KEY','FOREIGN KEY','NOT NULL','DEFAULT','A',1),
  (22,3,'What SQL clause filters results?','ORDER BY','GROUP BY','WHERE','HAVING','C',1),
  (23,3,'Which JOIN returns all rows from both tables?','INNER JOIN','LEFT JOIN','FULL OUTER JOIN','RIGHT JOIN','C',1),
  (24,3,'Which command adds new records?','ADD','INSERT INTO','CREATE','APPEND','B',1);

FLUSH PRIVILEGES;
EOF

echo "Database setup complete!"

# Download MySQL Connector JAR
echo "[6/6] Downloading MySQL JDBC Connector..."
cd /tmp
wget -q "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar" \
  -O mysql-connector-j-8.3.0.jar
echo "Download attempted - if failed, download manually from: https://dev.mysql.com/downloads/connector/j/"

echo ""
echo "================================================"
echo "  Setup Complete!"
echo "  Tomcat runs on: http://localhost:8080"
echo "  MySQL root password: root123"
echo "  Database: online_exam"
echo ""
echo "  Test login - Roll: S001, Password: pass123"
echo "================================================"
