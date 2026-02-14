--deleting tables if needed --
DROP TABLE Address;
DROP TABLE Department;
DROP TABLE Student;

--creating all the necessary tables --
CREATE TABLE Address(
address_id INT PRIMARY KEY,
street_address VARCHAR(50),
city VARCHAR(50),
State VARCHAR(50),
postal_code INT
);

CREATE TABLE department(
department_id INT PRIMARY KEY,
department_name VARCHAR(50) NOT NULL
);


CREATE TABLE Student(
student_id INT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
birthdate DATE,
department_id INT,
address_id INT,
FOREIGN KEY (department_id) REFERENCES
Department(department_id),
FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- inserting data into tables now --

INSERT INTO Department VALUES
(1,'Computer Science'),
(2,'Mechanical Engineering'),
(3,'Electrical Engineering'),
(4,'Civil Engineering'),
(5,'Mathematics'),
(6,'Biology')

SELECT * FROM Department;

INSERT INTO Address VALUES
(1,'123 Elm St','Springfield', 'IL', 62701),
(2,'456 Oak St',' Decatur', 'IL', 62521),
(3,'789 Pine St',' Champaign', 'IL', 61820),
(4,'102 Birch Rd',' Peoria', 'IL', 61602),
(5,'205 Cedar Ave ',' Chicago', 'IL', 60601),
(6,'310 Maple Dr ',' Urbana', 'IL', 61801),
(7,'415 Oak Blvd ',' Champaign', 'IL', 61821),
(8,'520 Pine Rd',' Carbondale', 'IL', 62901)

SELECT * FROM Address;

INSERT INTO Student VALUES
(1,'John','Doe','1995-04-15',1,1),
(2,'Jane','Smith','1996-07-22',2,2),
(3,'Alice','Johnson','1994-11-30',3,3),
(4,'Michael','Brown','1997-02-19',4,4),
(5,'Sophia','Davis','1998-01-05',5,5),
(6,'Daniel','Wilson','1995-06-10',6,6),
(7,'Olivia','Martinez','1997-11-25',1,7),
(8,'Ethan','Miller','1996-03-30',2,8)

SELECT * FROM Student
ORDER BY student_id

-- query to find the total number of students --
SELECT COUNT(*) FROM Student;

--query to find which department John belongs to --
SELECT d.department_name
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
WHERE s.first_name = 'John';

--Query to List All Departments with Their Number of Students --
WITH joined_table AS(
SELECT d.department_id, d.department_name, s.student_id
FROM Department d
LEFT JOIN Student s
ON s.department_id = d.department_id
)

SELECT department_id, department_name, COALESCE(COUNT(student_id),0) AS department_count
FROM joined_table
GROUP BY department_id, department_name;


--another way of writing this query --
SELECT d.department_id, d.department_name, COALESCE(COUNT(student_id),0) AS department_count
FROM Department d
RIGHT JOIN Student s
ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;

--Query to Select all students with their department and address --
SELECT s.student_id, s.first_name, s.last_name, d.department_name, a.street_address, a.city,a.state,a.postal_code
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
JOIN Address a
ON a.address_id = s.address_id;

-- Query to find all the students who are in the computer science department --
SELECT s.student_id, s.first_name, s.last_name
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
WHERE d.department_name = 'Computer Science';

--Update Jane’s city name to New York --
UPDATE Address
SET city = 'New York'
WHERE address_id = (SELECT address_id FROM Student WHERE first_name = 'Jane')

--Query to Delete a student from the student table --
DELETE FROM Student WHERE student_id = 8;

-- Query to Select all students with their department and address in New York --
SELECT s.student_id, s.first_name, s.last_name, d.department_name
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
JOIN Address a
ON a.address_id = s.address_id
WHERE a.city= 'New York';

-- Query to Count how many students are in each department --
SELECT department_id, COUNT(student_id) AS student_count
FROM Student
GROUP BY department_id
ORDER BY department_id;

-- Query to Find students who live in Spring Field --
SELECT s.student_id, s.first_name, s.last_name
FROM Student s
JOIN Address a
ON s.address_id = a.address_id
WHERE a.city = 'Springfield';

-- Query to Select students whose birthday falls in February --
SELECT student_id, first_name, last_name
FROM Student
WHERE EXTRACT(MONTH FROM birthdate) = 2

-- Query get the department and address details for a specific student, example john --
SELECT d.department_name, a.street_address, a.city, a.state, a.postal_code
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
JOIN Address a
ON a.address_id = s.address_id
WHERE s.first_name = 'John';

--Query to Find all students who are born within 1995 to 1998 --
SELECT student_id, first_name, last_name
FROM Student
WHERE EXTRACT(YEAR FROM birthdate) BETWEEN 1995 AND 1998;

-- Query list all students and their corresponding department names, sorted by department --
SELECT s.first_name, s.last_name, d.department_name
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
ORDER BY d.department_name

--Query to Find the number of students in each department who are living in Champaign --
SELECT d.department_id, SUM(CASE WHEN a.city ILIKE '%champaign' THEN 1 ELSE 0 END) AS students_in_champaign
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
JOIN Address a
ON a.address_id = s.address_id
GROUP BY d.department_id
ORDER BY d.department_id

-- Query to Retrieve the names of students who live on 'Pine street' --
SELECT s.first_name, s.last_name
FROM Student s
JOIN Address a
ON s.address_id = a.address_id
WHERE a.street_address ~* 'Pine St'


--Query to  Update the department of a student with student_id = 6 to 'Mechanical Engineering'  --
UPDATE Student
SET department_id = (SELECT department_id FROM department WHERE department_name = 'Mechanical Engineering')
WHERE student_id = 6;

-- Query to Find the student(s) who live in the city 'Chicago' and are in the 'Mathematics' department -- 
SELECT s.student_id, s.first_name, s.last_name, d.department_name, a.city
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
JOIN Address a
ON a.address_id = s.address_id
WHERE a.city ILIKE '%Chicago%' AND d.department_name ILIKE '%Mathematics%';

-- Query List all students who have an address in 'Urbana' or 'Peoria' --
SELECT s.student_id, s.first_name, s.last_name, a.city
FROM Student s
JOIN Address a
ON s.address_id = a.address_id
WHERE a.city ILIKE '%Urbana%' OR a.city ILIKE '%Peoria%'
ORDER BY student_id;

--Query to Find the student with the highest student_id --
SELECT s.student_id, s.first_name, s.last_name
FROM Student s
WHERE s.student_id = (SELECT MAX(s.student_id) FROM Student s)

--Query to Find all students who are not in the 'Computer Science' department --
SELECT s.student_id, s.first_name, s.last_name, d.department_name
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
WHERE d.department_name NOT ILIKE '%Computer Science%'
ORDER BY s.student_id

--Query to Count the total number of addresses in the 'Champaign' city --
SELECT city, COUNT(*) AS count_addresses
FROM Address
GROUP BY city

--Query to 'Find the name of the student who lives at '520 Pine Rd' 
SELECT s.first_name, s.last_name
FROM Student s
JOIN Address a
ON s.address_id = a.address_id
WHERE a.street_address ILIKE '%520 Pine Rd%'

--Query to find the average age of students in the Electrical Engineering Department --
--Since there is no age column in the student's table, creating one myself

ALTER TABLE Student
ADD COLUMN age INT

UPDATE Student
SET age = 20

UPDATE Student
SET age = 19 
WHERE first_name = 'Jane' OR first_name = 'Sophia';

UPDATE Student
SET age = 18
WHERE first_name = 'Olivia' OR first_name = 'Alice';


SELECT ROUND(AVG(age),2) AS average_age
FROM Student s
JOIN Department d
ON s.department_id = d.department_id
GROUP BY d.department_id
HAVING d.department_name ILIKE '%Electrical Engineering%';

/*Query to List the students, their department, and the city where they live, but only for those in 
departments starting with 'M' */
SELECT s.first_name, s.last_name, d.department_name, a.city
FROM Student s
JOIN Department d
ON d.department_id = s.department_id
JOIN Address a
ON a.address_id = s.address_id
WHERE LEFT(d.department_name,1) = 'M'

--Query to Delete student from Mechanical Engineering department
DELETE FROM 
Student WHERE department_id = 
(SELECT department_id FROM Department WHERE department_name ILIKE '%Mechanical Engineering%')





