SET search_path TO lab_tracker_group_22;

CREATE OR REPLACE VIEW ta_view AS
SELECT
    ls.lab_section_id                AS lab_section,
    e.le_id,
    s.student_id,
    s.student_first_name || ' ' ||
    s.student_last_name             AS full_name,
    p.pgr_attendance,
    p.pgr_inlab_submission_link,
    p.pgr_instructor_assessment
FROM progress p
JOIN student s
  ON p.pgr_student_id = s.student_id
JOIN lab_event e
  ON p.pgr_event_id = e.le_id
JOIN lab_section ls
  ON e.le_section_id = ls.lab_section_id;

CREATE OR REPLACE VIEW v_section_overview AS
SELECT
    t.term_code,
    ss.set_code AS set_name,
    c.course_code,
    ls.lab_section_id AS section_id,
    COUNT(DISTINCT le.le_id) AS total_events,
    AVG(CAST(p.pgr_instructor_assessment AS NUMERIC)) AS avg_instructor_assessment
FROM lab_section   AS ls
JOIN course        AS c  ON c.course_code = ls.lab_course_code
JOIN term          AS t  ON t.term_code   = ls.lab_term_code
JOIN student_set   AS ss ON ss.set_code   = ls.lab_set_code
LEFT JOIN lab_event AS le
       ON le.le_section_id = ls.lab_section_id
      AND le.course_code   = ls.lab_course_code
      AND le.term_code     = ls.lab_term_code
LEFT JOIN progress   AS p
       ON p.pgr_event_id = le.le_id
GROUP BY
    t.term_code,
    ss.set_code,
    c.course_code,
    ls.lab_section_id;

--everything from section
SELECT *
FROM v_section_overview
ORDER BY term_code, set_name, course_code, section_id;

-- only sections that actually have events
SELECT *
FROM v_section_overview
WHERE total_events > 0
ORDER BY total_events DESC;

--This is the view for ta
SELECT *
FROM ta_view;
