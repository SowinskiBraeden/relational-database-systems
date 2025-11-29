-- 1.
SELECT le_section_id, lab_set_code, course_code, la_title, lab_day_of_week
FROM lab_event
INNER JOIN lab_section
ON lab_section.lab_section_id = lab_event.le_section_id
INNER JOIN lab_assignment
ON lab_assignment.la_lab_number = lab_event.le_number
WHERE term_code = '202530';

-- 2.
SELECT pgr_student_id, COUNT(*) AS labs_attended
FROM progress
GROUP BY pgr_student_id;

-- 3.
SELECT pgr_student_id, student_set_code, lab_section_id, COUNT(*) FILTER (WHERE pgr_late 1= 'f') AS late_submissions
FROM progress
INNER JOIN student
ON student.student_id = progress.pgr_student_id
INNER JOIN lab_section
ON student.student_set_code = lab_section.lab_set_code
GROUP BY pgr_student_id, student_set_code, lab_section_id;

-- 4.
SELECT student_set_code, TO_CHAR(AVG(pgr_instructor_assessment::numeric), 'FM999999.00') AS section_average
FROM progress
INNER JOIN student
    ON student.student_id = progress.pgr_student_id
GROUP BY student_set_code
ORDER BY student_set_code;

-- 5.
SELECT student_first_name || ' ' || student_last_name AS student_name, student_set_code, le_number
FROM student
INNER JOIN progress
ON progress.pgr_student_id = student.student_id
INNER JOIN lab_event
ON lab_event.le_id = progress.pgr_event_id
WHERE pgr_instructor_assessment IS NULL OR pgr_self_assessment IS NULL;

-- 6.
SELECT student_id, student_first_name || ' ' || student_last_name AS student_name, student_set_code, TO_CHAR(AVG(pgr_instructor_assessment::numeric), 'FM999999.00') AS student_average
FROM student
JOIN progress
ON student.student_id = progress.pgr_student_id
GROUP BY student_id, student_first_name, student_last_name, student_set_code
HAVING AVG(pgr_instructor_assessment::numeric) >= 4.5
ORDER BY student_id;
