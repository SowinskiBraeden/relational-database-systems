TRUNCATE TABLE enrollment CASCADE;
TRUNCATE TABLE course_offering CASCADE;
TRUNCATE TABLE course CASCADE;
TRUNCATE TABLE term CASCADE;
TRUNCATE TABLE student CASCADE;
TRUNCATE TABLE professor CASCADE;
TRUNCATE TABLE department CASCADE;
TRUNCATE TABLE location CASCADE;

-- TASK 1

INSERT INTO location VALUES (
    'SE12',
    '240'
);

INSERT INTO location VALUES (
    'SE12',
    '260'
);

INSERT INTO location VALUES (
    'SW01',
    '1015'
);

INSERT INTO department VALUES (
    'COMP',
    'Computing',
    'Business & Media',
    '604-111-1111',
    'comp@bcit.ca',
    'https://bcit.ca/comp',
    'SE12 240'
);

INSERT INTO department VALUES (
    'MATH',
    'Mathematics',
    'Applied Sciences',
    '604-222-2222',
    'math@bcit.ca',
    'https://bcit.ca/math',
    'SE12 260'
);

INSERT INTO term VALUES (
    2025,
    'Fall'
);

INSERT INTO term VALUES (
    2026,
    'Winter'
);

INSERT INTO professor VALUES (
    'A00123456',
    'Ada',
    'Nguyen',
    'ada.nguyen@bcit.ca',
    '604-300-1111',
    '2019-08-15',
    'SE12 240',
    'COMP'
);

INSERT INTO professor VALUES (
    'A00987654',
    'Raj',
    'Singh',
    'raj.singh@bcit.ca',
    '604-300-2222',
    '2015-09-01',
    'SE12 260',
    'COMP'
);

INSERT INTO professor VALUES (
    'A00777777',
    'Maria',
    'Lopez',
    'maria.lopez@bcit.ca',
    '604-300-3333',
    '2012-01-10',
    'SW01 1015',
    'MATH'
);

INSERT INTO student VALUES (
    'A10000001',
    'Tom',
    'Anderson',
    'tom.anderson@my.bcit.ca',
    '604-777-1111',
    'CST',
    '202550',
    'COMP'
);

INSERT INTO student VALUES (
    'A10000002',
    'Sara',
    'Young',
    'sara.young@my.bcit.ca',
    '604-777-2222',
    'CST',
    '202550',
    'COMP'
);

INSERT INTO student VALUES (
    'A10000003',
    'Reena',
    'Patel',
    'reena.patel@my.bcit.ca',
    '604-777-3333',
    'ACIT',
    '202550',
    'COMP'
);

INSERT INTO student VALUES (
    'A10000004',
    'Min',
    'Chen',
    'min.chen@my.bcit.ca',
    '604-777-4444',
    'MATH',
    '202610',
    'MATH'
);

INSERT INTO course VALUES (
    'COMP',
    2714,
    'Relational Database Systems',
    4.0,
    'COMP',
    'Core RDBMS course'
);

INSERT INTO course VALUES (
    'COMP',
    1537,
    'Web Development 1',
    3.0,
    'COMP',
    'Intro to web dev'
);

INSERT INTO course VALUES (
    'MATH',
    3042,
    'Discrete Mathematics',
    4.0,
    'MATH',
    'Proofs & structures'
);

INSERT INTO course_offering (
    off_crs_code, off_term_code, off_section, off_type,
    off_prof, off_days, off_start_time, off_end_time,
    off_loc, off_capacity
) VALUES (
    'COMP 2714',
    '202550',
    'LEC',
    'Lecture',
    'A00123456',
    'Mon,Wed',
    '09:30',
    '11:20',
    'SE12 240',
    '60'
);

INSERT INTO course_offering (
    off_crs_code, off_term_code, off_section, off_type,
    off_prof, off_days, off_start_time, off_end_time,
    off_loc, off_capacity
) VALUES (
    'COMP 2714',
    '202550',
    'L1',
    'Lab',
    'A00987654',
    'Fri',
    '12:30',
    '14:20',
    'SE12 260',
    '24'
);

INSERT INTO enrollment VALUES (
    'A10000001',
    1,
    'Active',
    NULL
);

INSERT INTO enrollment VALUES (
    'A10000002',
    1,
    'Active',
    NULL
);

INSERT INTO enrollment VALUES (
    'A10000003',
    1,
    'Active',
    NULL
);

INSERT INTO enrollment VALUES (
    'A10000001',
    2,
    'Active',
    NULL
);

INSERT INTO enrollment VALUES (
    'A10000002',
    2,
    'Active',
    NULL
);

-- TASK 2
INSERT INTO student VALUES (
    'A01385066',
    'Braeden',
    'Sowinski',
    'bsowinski@my.bcit.ca',
    '778-208-8109',
    'CST',
    '202550',
    'COMP'
);

INSERT INTO professor VALUES (
    'A11223344',
    'Jason',
    'Wilder',
    'jason.wilder@bcit.ca',
    '777-666-5555',
    '2020-01-01',
    'SE12 260',
    'COMP'
);

INSERT INTO course_offering (
    off_crs_code, off_term_code, off_section, off_type,
    off_prof, off_days, off_start_time, off_end_time,
    off_loc, off_capacity
) VALUES (
    'COMP 2714',
    '202550',
    'L2',
    'Lab',
    'A11223344',
    'Tue',
    '13:30',
    '15:20',
    'SE12 260',
    '20'
);

INSERT INTO enrollment VALUES (
    'A01385066',
    3,
    'Active',
    NULL
);

INSERT INTO enrollment VALUES (
    'A10000002',
    3,
    'Active',
    NULL
);

-- TASK 3
-- Insert location for update
INSERT INTO location (loc_building, loc_room)
VALUES ('SW01', '1015')
ON CONFLICT DO NOTHING;  -- if already exists, skip

UPDATE course_offering
SET off_days = 'Thu',
    off_start_time = '15:30',
    off_end_time = '17:20',
    off_loc = 'SW01 1015'
WHERE off_section = 'L1';

-- Update student A10000002 for course_offering 3
UPDATE enrollment
SET enr_status = 'Dropped'
WHERE off_id = 3 -- L2 Lab Comp 2714
AND stu_num = 'A10000002'; -- Sara Young

UPDATE enrollment
SET enr_status = 'Active'
WHERE off_id = 3 -- L2 Lab Comp 2714
AND stu_num = 'A10000002'; -- Sara Young

-- Update grades
UPDATE enrollment
SET enr_final_grade = 'A'
WHERE off_id = 1 -- Lecture Comp 2714
AND stu_num = 'A10000001'; -- Tom Anderson

UPDATE enrollment
SET enr_final_grade = 'A'
WHERE off_id = 1 -- Lecture Comp 2714
AND stu_num = 'A10000003'; -- Reena Patel

-- TASK 4

-- DELETE FROM department
-- WHERE dep_code = 'COMP';

-- DELETE FROM course_offering
-- WHERE off_section = 'L2';

-- DELETE FROM location
-- WHERE loc_code = 'SE12 260';
