DROP SCHEMA IF EXISTS lab_tracker_group_22 CASCADE;
CREATE SCHEMA lab_tracker_group_22;
SET search_path TO lab_tracker_group_22;

DROP TABLE IF EXISTS progress_change_log;
DROP TABLE IF EXISTS progress;
DROP TABLE IF EXISTS lab_event;
DROP TABLE IF EXISTS lab_assignment;
DROP TABLE IF EXISTS student_section;
DROP TABLE IF EXISTS lab_section;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS user_account;
DROP TABLE IF EXISTS student_set;
DROP TABLE IF EXISTS term;
DROP TABLE IF EXISTS course;

CREATE TABLE course (
 course_code    VARCHAR(20)  CONSTRAINT pk_course PRIMARY KEY,
 course_title   VARCHAR(200),
 credits        NUMERIC(3,0)
   CONSTRAINT ck_course_credits CHECK (credits BETWEEN 1 AND 9)
);

CREATE TABLE term (
 term_code        VARCHAR(10)  CONSTRAINT pk_term PRIMARY KEY,
 term_name        VARCHAR(50),
 term_start_date  DATE,
 term_end_date    DATE,
 CONSTRAINT ck_term_code_fmt CHECK (term_code ~ '^[0-9]{6}$')
);

CREATE TABLE student_set (
 set_code     VARCHAR(10) CONSTRAINT pk_student_set PRIMARY KEY,
 set_campus   VARCHAR(50)
);

CREATE TABLE user_account (
 user_id        VARCHAR(50) CONSTRAINT pk_user_account PRIMARY KEY,
 user_full_name VARCHAR(120) NOT NULL,
 user_role      VARCHAR(30),
 user_email     VARCHAR(120) CONSTRAINT uq_user_email UNIQUE
);


CREATE TABLE student (
 student_id         VARCHAR(30) CONSTRAINT pk_student PRIMARY KEY,
 student_set_code   VARCHAR(10)  NOT NULL,
 student_first_name VARCHAR(80)  NOT NULL,
 student_last_name  VARCHAR(80)  NOT NULL,
 student_email      VARCHAR(120),
 CONSTRAINT uq_student_email UNIQUE (student_email),
 CONSTRAINT fk_student_set
   FOREIGN KEY (student_set_code)
   REFERENCES student_set(set_code)
   ON UPDATE CASCADE
);

CREATE TABLE lab_section (
 lab_section_id     VARCHAR(20) CONSTRAINT pk_lab_section PRIMARY KEY,
 lab_course_code    VARCHAR(20) NOT NULL,
 lab_term_code      VARCHAR(10) NOT NULL,
 lab_set_code       VARCHAR(10) NOT NULL,
 lab_section_type   VARCHAR(10),
 lab_day_of_week    VARCHAR(10),
 lab_start_time     TIME,
 lab_end_time       TIME,
 lab_location       VARCHAR(100),

 CONSTRAINT fk_lab_section_course FOREIGN KEY (lab_course_code)
   REFERENCES course(course_code) ON UPDATE CASCADE,
 CONSTRAINT fk_lab_section_term FOREIGN KEY (lab_term_code)
   REFERENCES term(term_code) ON UPDATE CASCADE,
 CONSTRAINT fk_lab_section_set FOREIGN KEY (lab_set_code)
   REFERENCES student_set(set_code) ON UPDATE CASCADE,

 CONSTRAINT uq_lab_section_triplet
   UNIQUE (lab_section_id, lab_course_code, lab_term_code)
);

CREATE TABLE student_section (
 ss_section_id  VARCHAR(20) NOT NULL,
 ss_student_id  VARCHAR(30) NOT NULL,
 CONSTRAINT pk_student_section PRIMARY KEY (ss_section_id, ss_student_id),
 CONSTRAINT fk_student_section_section FOREIGN KEY (ss_section_id)
   REFERENCES lab_section(lab_section_id) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT fk_student_section_student FOREIGN KEY (ss_student_id)
   REFERENCES student(student_id) ON UPDATE CASCADE
);

CREATE TABLE lab_assignment (
 la_assignment_id  VARCHAR(20) CONSTRAINT pk_lab_assignment PRIMARY KEY,   la_course_code    VARCHAR(20) NOT NULL,
 la_term_code      VARCHAR(10),
 la_lab_number     INTEGER,
 la_title          VARCHAR(200),
 CONSTRAINT fk_assignment_course FOREIGN KEY (la_course_code)
   REFERENCES course(course_code) ON UPDATE CASCADE,
 CONSTRAINT fk_assignment_term FOREIGN KEY (la_term_code)
   REFERENCES term(term_code) ON UPDATE CASCADE
);

CREATE TABLE lab_event (
 le_id          VARCHAR(32) CONSTRAINT pk_lab_event PRIMARY KEY,
 le_section_id  VARCHAR(20) NOT NULL,
 course_code    VARCHAR(20) NOT NULL,
 term_code      VARCHAR(10) NOT NULL,
 le_number      INTEGER NOT NULL,
 le_starts_at   TIMESTAMP NOT NULL,
 le_ends_at     TIMESTAMP NOT NULL,
 le_due_at      TIMESTAMP,
 le_location    VARCHAR(100),

 CONSTRAINT fk_event_section_triplet
   FOREIGN KEY (le_section_id, course_code, term_code)
   REFERENCES lab_section (lab_section_id, lab_course_code, lab_term_code)
   ON UPDATE CASCADE
   ON DELETE CASCADE,

 CONSTRAINT ck_event_time_order CHECK (le_ends_at > le_starts_at)
);

CREATE TABLE progress (
 pgr_id                        VARCHAR(50)  CONSTRAINT pk_progress PRIMARY KEY,
 pgr_student_id                VARCHAR(30)  NOT NULL,
 pgr_event_id                  VARCHAR(32)  NOT NULL,
 pgr_lab_number                INTEGER,
 pgr_status                    VARCHAR(50),
 pgr_prepared                  BOOLEAN     NOT NULL DEFAULT FALSE,
 pgr_attendance                VARCHAR(20),
 pgr_inlab_submitted_at        TIMESTAMP,
 pgr_inlab_submission_link     TEXT,
 pgr_polished_submitted_at     TIMESTAMP,
 pgr_polished_submission_link  TEXT,
 pgr_instructor_assessment     TEXT,
 pgr_self_assessment           TEXT,
 pgr_late                      BOOLEAN     NOT NULL DEFAULT FALSE,

 CONSTRAINT fk_prog_student
   FOREIGN KEY (pgr_student_id)
   REFERENCES student(student_id)
   ON UPDATE CASCADE,

  CONSTRAINT fk_prog_event
   FOREIGN KEY (pgr_event_id)
   REFERENCES lab_event(le_id)
   ON UPDATE CASCADE
   ON DELETE CASCADE,

 CONSTRAINT ck_prog_time_order CHECK (
   pgr_polished_submitted_at IS NULL
   OR pgr_inlab_submitted_at IS NULL
   OR pgr_polished_submitted_at >= pgr_inlab_submitted_at
 )
);

CREATE TABLE progress_change_log (
 chl_change_id    VARCHAR(20)  CONSTRAINT pk_progress_change_log PRIMARY KEY,
 chl_progress_id  VARCHAR(50)  NOT NULL,
 chl_changed_by   VARCHAR(50)  NOT NULL,
 chl_changed_at   TIMESTAMP    NOT NULL,
 chl_field        VARCHAR(100) NOT NULL,
 chl_old_value    VARCHAR(255),
 chl_new_value    VARCHAR(255),
 chl_reason       TEXT,
 CONSTRAINT fk_chglog_progress FOREIGN KEY (chl_progress_id)
   REFERENCES progress(pgr_id) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT fk_chglog_user FOREIGN KEY (chl_changed_by)
   REFERENCES user_account(user_id) ON UPDATE CASCADE
);
