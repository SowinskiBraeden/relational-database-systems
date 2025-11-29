-- 1. Create a role for TAs
CREATE ROLE ta_role;

-- 2. Allow this role to view your TA-related views
GRANT SELECT ON v_ta_progress_summary, v_section_overview TO ta_role;

-- 3. Create a demo user (only works if your server allows user creation)
CREATE USER ta_demo WITH PASSWORD 'ta_demo123';

-- 4. Give the demo user the TA role
GRANT ta_role TO ta_demo;
