-- Braeden Sowinski
-- Set 2D

SET search_path TO lab5;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'lab5';

-- Quick peek per table
SELECT * FROM student LIMIT 5;

-- ### PART 1 - Basic SELECT ###

-- Q1.1 List all students’ first and last names.
SELECT stu_fname, stu_lname FROM student;

-- Q1.2 List all courses (code + title).
SELECT crs_code, crs_title FROM course;

-- Q1.3 Show all lab offerings for for COMP 2714 in Fall 2025 (days + start time).
SELECT off_days, off_start_time
FROM course_offering
WHERE off_crs_code = 'COMP 2714'
AND off_term_code = '202550' -- Fall 2025
AND off_type = 'Lab';

-- Q1.4 Display all rows from your enrollment table.
SELECT * FROM enrollment;

-- ### PART 2 - INNER JOIN Practice ###

-- Q2.1 List all students and the sections they are enrolled in. Include student name, section id, and term.
SELECT student.stu_fname, course_offering.off_section, course_offering.off_term_code
FROM student
INNER JOIN enrollment
ON student.stu_num = enrollment.stu_num
INNER JOIN course_offering
ON enrollment.off_id = course_offering.off_id;

-- Q2.2 Show all course offerings with their course titles.
SELECT course_offering.off_id, course_offering.off_section, course_offering.off_type, course.crs_title
FROM course_offering
INNER JOIN course
ON course_offering.off_crs_code = course.crs_code;

-- Q2.3 Display enrollments with the course title and the meeting days.
SELECT enrollment.stu_num, enrollment.enr_status, course.crs_title, course_offering.off_days
FROM enrollment
INNER JOIN course_offering
ON enrollment.off_id = course_offering.off_id
INNER JOIN course
ON course_offering.off_crs_code = course.crs_code;

-- ### PART 3 - FILTERING & SORTING ###

-- Q3.1 Students enrolled in Fall 2025 only (term code 202550).
SELECT student.stu_fname, enrollment.enr_status, course_offering.off_term_code
FROM student
INNER JOIN enrollment
ON student.stu_num = enrollment.stu_num
INNER JOIN course_offering
ON enrollment.off_id = course_offering.off_id
WHERE off_term_code = '202550';

-- Q3.2 Courses whose title contains the word Database (case-insensitive).
SELECT *
FROM course
WHERE LOWER(crs_title) LIKE LOWER('%database%');
-- No contains? LOWER() ensures that it doesnt matter if upper or lower case

-- Q3.4 Students whose last name begins with C.
SELECT *
FROM student
WHERE stu_lname LIKE 'C%';

-- ### PART 4 - OUTER JOINs & NULLs

-- Q4.1 All students with their enrollment info, including students with no enrollments (use LEFT JOIN).
SELECT student.stu_fname, enrollment.*
FROM student
LEFT JOIN enrollment
ON student.stu_num = enrollment.stu_num;

-- Q4.2 Courses not offered in the current term.
SELECT course.crs_title, course.crs_subject, course.crs_credits
FROM course
LEFT JOIN course_offering
ON course_offering.off_crs_code = course.crs_code
WHERE course_offering.off_term_code IS NULL;

-- ### REFLECTION ###
--
-- Yes, all of the row counts make sense, there may
-- be some duplicatoin. For example, when we are
-- getting all student ids, and their enrollments,
-- there may be duplicate enrollment data.
-- i.e. two students are enrolled in the same
-- course_offering. However, we since we are showing
-- the student_id we are able to tell them apart.

-- I dont think distinct would change the result
-- in the example above, there is student x enrolled
-- in class A, and student y enrolled in class A too.
-- Those are already distinct.

-- Yes I think I am selecting the minimul necessary
-- columns, only showing relavent related information.
