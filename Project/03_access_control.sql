SET search_path TO lab_tracker_group_22;

-- 1. Create a role for TAs
CREATE ROLE ta_role;

-- 2. Allow this role to view your TA-related views
GRANT SELECT ON ta_view, v_section_overview TO ta_role;
GRANT USAGE ON SCHEMA lab_tracker_group_22 TO ta_role;

-- 3. Create a demo user
CREATE USER ta_demo WITH PASSWORD 'superdupercoolta69';

-- 4. Give the demo user the TA role
GRANT ta_role TO ta_demo;

-- test
SET ROLE ta_role;

SELECT * FROM ta_view;
