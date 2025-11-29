
-- Show all students with their section info Should work
SELECT s.student_first_name, s.student_last_name, ls.lab_course_code, c.course_title, t.term_name
FROM student s
JOIN student_section ss ON s.student_id = ss.ss_student_id
JOIN lab_section ls ON ss.ss_section_id = ls.lab_section_id
JOIN course c ON ls.lab_course_code = c.course_code
JOIN term t ON ls.lab_term_code = t.term_code;

-- Count students per lab section Should work
SELECT ls.lab_course_code, COUNT(ss.ss_student_id) AS total_students
FROM lab_section ls
LEFT JOIN student_section ss ON ls.lab_section_id = ss.ss_section_id
GROUP BY ls.lab_course_code;

-- View audit log Should work as intended
SELECT pcl.chl_change_id, ua.user_full_name AS actor, pcl.chl_reason, pcl.chl_changed_at
FROM progress_change_log pcl
JOIN user_account ua ON pcl.chl_changed_by = ua.user_id;

-- returns students names and sets
SELECT student_first_name, student_last_name, student_set_code
FROM student ORDER BY student_set_code ASC;

-- This should fail and not work
INSERT INTO course (course_code, course_title, credits)
VALUES ('COMP9999', 'Invalid Credits', 0);

-- Delete a lab section -> should also delete lab_event
-- and progress automatically cause of cascade
DELETE FROM lab_section WHERE lab_section_id = 'L01';

-- Check remaining events and progress
-- all should be empty due to cascade
SELECT * FROM lab_event WHERE lab_event.le_section_id = 'L01';

SELECT * FROM progress JOIN lab_event ON progress.pgr_event_id = lab_event.le_id
WHERE lab_event.le_section_id = 'L01';

SELECT * FROM progress_change_log JOIN progress ON progress_change_log.chl_progress_id = progress.pgr_id
JOIN lab_event ON progress.pgr_event_id = lab_event.le_id
WHERE lab_event.le_section_id = 'L01';
