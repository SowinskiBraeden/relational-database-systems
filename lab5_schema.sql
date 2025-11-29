-- 1. Create a schema for this lab (only runs once)
CREATE SCHEMA IF NOT EXISTS lab5;

-- 2. Tell PostgreSQL to use this schema by default
SET search_path TO lab5;

-- 3. Safety header: drop old tables if they exist
DROP TABLE IF EXISTS location CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS professor CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS term CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS course_offering CASCADE;
DROP TABLE IF EXISTS enrollment CASCADE;

-- 4. Create tables for lab5
CREATE TABLE location (
    loc_building VARCHAR(10) NOT NULL,
    loc_room     VARCHAR(10) NOT NULL,
    loc_code     VARCHAR(20) GENERATED ALWAYS AS (
                    loc_building || ' ' || loc_room
                 ) STORED PRIMARY KEY
);

CREATE TABLE department (
    dep_code    VARCHAR(10) PRIMARY KEY,
    dep_name    VARCHAR(50) NOT NULL,
    dep_school  VARCHAR(50) NOT NULL,
    dep_phone   VARCHAR(12) NOT NULL,
    dep_email   VARCHAR(50) NOT NULL,
    dep_website VARCHAR(50) NOT NULL,
    loc_code    VARCHAR(10) REFERENCES location(loc_code)
);

CREATE TABLE professor (
    prof_num    VARCHAR(20) PRIMARY KEY,
    prof_fname  VARCHAR(20) NOT NULL,
    prof_lname  VARCHAR(20) NOT NULL,
    prof_email  VARCHAR(50) NOT NULL,
    prof_phone  VARCHAR(12) NOT NULL,
    prof_hired  DATE        NOT NULL,
    prof_office VARCHAR(20) REFERENCES location(loc_code) NOT NULL,
    dep_code    VARCHAR(50) REFERENCES department(dep_code) NOT NULL
);

CREATE TABLE term (
    term_year       INTEGER     NOT NULL,
    term_semester   VARCHAR(10) NOT NULL,
    term_name       VARCHAR(30) GENERATED ALWAYS AS (
                        term_semester || ' ' || (term_year::text)
                    ) STORED,

    term_code       VARCHAR(6)  GENERATED ALWAYS AS (
        (term_year::text) ||
        CASE term_semester
            WHEN 'Winter' THEN '10'
            WHEN 'Spring' THEN '30'
            WHEN 'Summer' THEN '40'
            WHEN 'Fall'   THEN '50'
        END
    ) STORED,

    CONSTRAINT term_pk PRIMARY KEY (term_code),
    CONSTRAINT term_semester_ck CHECK (term_semester IN ('Winter','Spring','Summer','Fall'))
);

CREATE TABLE student (
    stu_num     VARCHAR(20)  PRIMARY KEY,
    stu_fname   VARCHAR(20)  NOT NULL,
    stu_lname   VARCHAR(20)  NOT NULL,
    stu_email   VARCHAR(50)  NOT NULL,
    stu_phone   VARCHAR(12)  NOT NULL,
    stu_program VARCHAR(5)   NOT NULL,
    stu_term    VARCHAR(6)   REFERENCES term(term_code) NOT NULL,
    stu_dept    VARCHAR(10)  REFERENCES department(dep_code) NOT NULL
);

CREATE TABLE course (
    crs_subject VARCHAR(10)  REFERENCES department(dep_code) NOT NULL,
    crs_num     INTEGER      NOT NULL,
    crs_title   VARCHAR(50)  NOT NULL,
    crd_credits NUMERIC(3,1) NOT NULL,
    dep_code    VARCHAR(10)  REFERENCES department(dep_code) NOT NULL,
    crs_desc    TEXT         NOT NULL,

    crs_code    VARCHAR(60)  GENERATED ALWAYS AS (
                                dep_code || ' ' || crs_num::text
                             ) STORED PRIMARY KEY
);

CREATE TABLE course_offering (
    off_id         SERIAL       PRIMARY KEY,
    off_crs_code   VARCHAR(60)  REFERENCES course(crs_code) NOT NULL,
    off_term_code  VARCHAR(6)   REFERENCES term(term_code) NOT NULL,
    off_section    VARCHAR(50)  NOT NULL,
    off_type       VARCHAR(10)  NOT NULL,
    off_prof       VARCHAR(20)  REFERENCES professor(prof_num) NOT NULL,
    off_days       VARCHAR(100) NOT NULL,
    off_start_time TIME         NOT NULL,
    off_end_time   TIME         NOT NULL,
    off_loc        VARCHAR(20)  REFERENCES location(loc_code) NOT NULL,
    off_capacity   INTEGER      NOT NULL,

    CONSTRAINT off_type_ck CHECK (off_type IN ('Lecture','Lab'))
);

CREATE TABLE enrollment (
    stu_num         VARCHAR(20) REFERENCES student(stu_num) NOT NULL,
    off_id          INTEGER     REFERENCES course_offering(off_id) NOT NULL,
    enr_status      VARCHAR(8)  NOT NULL,
    enr_final_grade VARCHAR(2),

    CONSTRAINT enr_pk PRIMARY KEY (stu_num, off_id),
    CONSTRAINT enr_status_ck CHECK (enr_status IN ('Active', 'Dropped'))
);
