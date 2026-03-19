# Online Examination System
## Complete Ubuntu Deployment Guide

---

## Tech Stack
- **OS**: Ubuntu 22.04 / 24.04 LTS
- **Java**: OpenJDK 11
- **Server**: Apache Tomcat 10
- **Database**: MySQL 8
- **Frontend**: JSP + CSS (dark theme)

---

## STEP 1 — Install Java, Tomcat, MySQL

Run these commands one by one in your terminal:

```bash
sudo apt update && sudo apt upgrade -y

# Install Java JDK 11
sudo apt install openjdk-11-jdk -y
java -version    # should print: openjdk 11...

# Install Apache Tomcat 10
sudo apt install tomcat10 tomcat10-admin -y
sudo systemctl start tomcat10
sudo systemctl enable tomcat10

# Verify Tomcat is running
sudo systemctl status tomcat10
# Open browser → http://localhost:8080  (you should see Tomcat page)

# Install MySQL Server
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
```

---

## STEP 2 — Setup MySQL Database

```bash
# Secure MySQL
sudo mysql_secure_installation
# Set root password: exam@2024
# Answer Y to all remaining prompts

# Login to MySQL
sudo mysql -u root -p
# Enter password: exam@2024
```

Now paste this entire SQL block:

```sql
CREATE DATABASE IF NOT EXISTS online_exam;
USE online_exam;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  roll_number VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  subject VARCHAR(100),
  duration_minutes INT NOT NULL DEFAULT 30,
  total_marks INT NOT NULL,
  description TEXT,
  is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE questions (
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

CREATE TABLE results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  exam_id INT NOT NULL,
  score INT NOT NULL,
  total INT NOT NULL,
  attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (exam_id) REFERENCES exams(id)
);

-- Sample students
INSERT INTO users (roll_number, name, password, email) VALUES
  ('S001', 'Swathi',  'pass123', 'swathi@example.com'),
  ('S002', 'Sathya',   'pass123', 'sathya@example.com'),
  ('S003', 'Veera',   'pass123', 'veera@example.com');
  ('S003', 'Vidhya',   'pass123', 'vidhya@example.com');

-- Sample exams
INSERT INTO exams (title, subject, duration_minutes, total_marks, description) VALUES
  ('Java Programming Fundamentals', 'Computer Science', 30, 10, 'Test your Java basics knowledge'),
  ('Python Essentials',             'Computer Science', 25,  8, 'Core Python programming concepts'),
  ('Database Management',           'Information Technology', 20, 6, 'SQL and database fundamentals');

-- Java questions (exam_id=1)
INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(1,'Which keyword creates an object in Java?','class','new','object','create','B',1),
(1,'What is the default value of an int in Java?','null','0','undefined','-1','B',1),
(1,'Which is NOT a Java primitive type?','int','String','float','char','B',1),
(1,'What does JVM stand for?','Java Virtual Machine','Java Variable Method','Java Verified Module','Just Virtual Machine','A',1),
(1,'Which method is the entry point of a Java program?','start()','run()','main()','init()','C',1),
(1,'What is the size of int in Java?','2 bytes','4 bytes','8 bytes','16 bytes','B',1),
(1,'Which keyword is used for inheritance?','implements','inherits','extends','super','C',1),
(1,'What does OOP stand for?','Object Oriented Programming','Object Operating Process','Optional Object Protocol','Output Oriented Procedure','A',1),
(1,'Which collection does NOT allow duplicates?','ArrayList','LinkedList','Set','Vector','C',1),
(1,'What is used to handle exceptions in Java?','try-catch','if-else','switch','loop','A',1);

-- Python questions (exam_id=2)
INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(2,'Which symbol is used for single-line comments in Python?','//','#','/*','--','B',1),
(2,'What is the correct way to create a list in Python?','list = ()','list = {}','list = []','list = <>','C',1),
(2,'Which function returns the length of a list?','size()','count()','len()','length()','C',1),
(2,'What is the output of type(3.14)?','int','str','float','double','C',1),
(2,'Which keyword defines a function in Python?','function','def','fun','method','B',1),
(2,'What is the result of 10 // 3 in Python?','3.33','3','4','1','B',1),
(2,'Which data type is immutable in Python?','list','dict','set','tuple','D',1),
(2,'What does pip stand for?','Python Install Package','Pip Installs Packages','Package Install Python','Python Index Package','B',1);

-- DB questions (exam_id=3)
INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(3,'What does SQL stand for?','Structured Query Language','Simple Query Language','Structured Question Logic','Sequential Query List','A',1),
(3,'Which SQL command retrieves data?','INSERT','UPDATE','SELECT','DELETE','C',1),
(3,'Which constraint ensures unique values in a column?','FOREIGN KEY','NOT NULL','UNIQUE','DEFAULT','C',1),
(3,'Which SQL clause filters results?','ORDER BY','GROUP BY','WHERE','HAVING','C',1),
(3,'Which JOIN returns all rows from both tables?','INNER JOIN','LEFT JOIN','FULL OUTER JOIN','RIGHT JOIN','C',1),
(3,'Which command adds new records to a table?','ADD','INSERT INTO','CREATE','APPEND','B',1);

FLUSH PRIVILEGES;
EXIT;
```

---

## STEP 3 — Download MySQL JDBC Connector

```bash
cd /tmp
wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar

# Copy to project's WEB-INF/lib
cp mysql-connector-j-8.3.0.jar /path/to/OnlineExam/WebContent/WEB-INF/lib/
```

**OR** download manually:
1. Go to: https://dev.mysql.com/downloads/connector/j/
2. Select "Platform Independent" → Download the ZIP
3. Extract and copy the `.jar` to `WebContent/WEB-INF/lib/`

---

## STEP 4 — Install Eclipse IDE

```bash
# Install Eclipse Enterprise Edition
sudo snap install eclipse --classic

# OR download manually:
# https://www.eclipse.org/downloads/packages/
# Choose: "Eclipse IDE for Enterprise Java and Web Developers"
# Extract and run: ./eclipse/eclipse
```

---

## STEP 5 — Import & Configure Project in Eclipse

1. Open Eclipse → **File → Import → Existing Projects into Workspace**
2. Browse to the `OnlineExam` folder → Finish
3. Right-click project → **Build Path → Configure Build Path**
4. Add **External JARs** → select `mysql-connector-j-8.3.0.jar`
5. Also add Tomcat's servlet API:
   - Add Library → **Server Runtime** → Apache Tomcat 10
6. Edit `src/com/exam/db/DBConnection.java`:
   - Change `PASSWORD = "exam@2024"` to your MySQL root password if different

---

## STEP 6 — Deploy to Tomcat

**Option A — Eclipse (recommended for development):**
1. Right-click project → **Run As → Run on Server**
2. Select Apache Tomcat 10 → Finish
3. Browser auto-opens at `http://localhost:8080/OnlineExam/`

**Option B — Manual WAR deployment:**
```bash
# Build WAR in Eclipse: File → Export → WAR file → save as OnlineExam.war

# Copy to Tomcat webapps
sudo cp OnlineExam.war /var/lib/tomcat10/webapps/

# Tomcat auto-deploys it
sudo systemctl restart tomcat10

# Access at:
# http://localhost:8080/OnlineExam/
```

---

## STEP 7 — Test the Application

Open browser → `http://localhost:8080/OnlineExam/`

| Student | Roll No | Password |
|---------|---------|----------|
| Swathi  | S001 | pass123 |
| Sathya  | S002 | pass123 |
| Veera   | S003 | pass123 |

**Flow:**
1. Login with roll number + password
2. Select an exam from the list
3. Answer questions (timer counts down)
4. Submit → see score, percentage, and full answer review

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Copy JAR to `WEB-INF/lib/` |
| `Access denied for user 'root'` | Check password in DBConnection.java |
| Tomcat 404 on `/OnlineExam/` | Check project context root in Eclipse server config |
| `Communications link failure` | `sudo systemctl start mysql` |
| Port 8080 in use | `sudo lsof -i :8080` then kill that process |

---

## Project File Structure (Final)

```
OnlineExam/
├── src/com/exam/
│   ├── db/DBConnection.java
│   ├── model/User.java  Exam.java  Question.java  Result.java
│   ├── dao/UserDAO.java  ExamDAO.java  QuestionDAO.java  ResultDAO.java
│   └── servlet/LoginServlet.java  LogoutServlet.java
│               ExamListServlet.java  ExamServlet.java  SubmitServlet.java
├── WebContent/
│   ├── WEB-INF/
│   │   ├── web.xml
│   │   └── lib/mysql-connector-j-8.3.0.jar   ← place JAR here
│   ├── css/style.css
│   ├── login.jsp
│   ├── exams.jsp
│   ├── exam.jsp
│   └── result.jsp
```
