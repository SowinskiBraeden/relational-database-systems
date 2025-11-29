SET search_path TO lab5;

-- TASK 1 – Enforce Section Capacity

-- 1. Trigger function: ensure no course offering exceeds capacity
CREATE OR REPLACE FUNCTION check_offering_capacity()
RETURNS TRIGGER AS $$
DECLARE
    v_capacity INTEGER;
    v_current  INTEGER;
BEGIN
    SELECT off_capacity
    INTO v_capacity
    FROM course_offering
    WHERE off_id = NEW.off_id;

    SELECT COUNT(*)
    INTO v_current
    FROM enrollment
    WHERE off_id = NEW.off_id
      AND enr_status = 'Active';

    IF v_current >= v_capacity THEN
        RAISE EXCEPTION
            'Cannot enroll student %. Section % is full (capacity=%).',
            NEW.stu_num, NEW.off_id, v_capacity;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 2. Trigger
CREATE OR REPLACE TRIGGER trg_check_capacity
BEFORE INSERT ON enrollment
FOR EACH ROW
EXECUTE FUNCTION check_offering_capacity();

-- TASK 2 – Enrollment Audit Logging

CREATE TABLE IF NOT EXISTS enrollment_audit (
    audit_id      SERIAL PRIMARY KEY,
    enr_id_stu    VARCHAR(20),
    enr_id_off    INTEGER,
    action_type   VARCHAR(10),
    old_status    VARCHAR(8),
    new_status    VARCHAR(8),
    action_ts     TIMESTAMP DEFAULT NOW(),
    action_user   TEXT DEFAULT current_user
);

CREATE OR REPLACE FUNCTION audit_enrollment_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO enrollment_audit(
            enr_id_stu,
            enr_id_off,
            action_type,
            new_status
        )
        VALUES (
            NEW.stu_num,
            NEW.off_id,
            'INSERT',
            NEW.enr_status
        );

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO enrollment_audit(
            enr_id_stu,
            enr_id_off,
            action_type,
            old_status,
            new_status
        )
        VALUES (
            NEW.stu_num,
            NEW.off_id,
            'UPDATE',
            OLD.enr_status,
            NEW.enr_status
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_enrollment_audit
AFTER INSERT OR UPDATE ON enrollment
FOR EACH ROW
EXECUTE FUNCTION audit_enrollment_changes();

-- TASK 3 – Validate Enrollment Status

ALTER TABLE enrollment DROP CONSTRAINT IF EXISTS enr_status_ck;

ALTER TABLE enrollment
ADD CONSTRAINT enr_status_ck
CHECK (enr_status IN ('Active', 'Dropped', 'Completed', 'Failed'));

CREATE OR REPLACE FUNCTION validate_enrollment_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.enr_status NOT IN ('Active','Dropped','Completed','Failed') THEN
        RAISE EXCEPTION 'Invalid enrollment status: %', NEW.enr_status;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_validate_status
BEFORE INSERT OR UPDATE OF enr_status ON enrollment
FOR EACH ROW
EXECUTE FUNCTION validate_enrollment_status();

-- TESTS

INSERT INTO enrollment VALUES ('S100', 1, 'Active');
INSERT INTO enrollment VALUES ('S101', 1, 'Active');
INSERT INTO enrollment VALUES ('S102', 1, 'Active');

INSERT INTO enrollment VALUES ('S200', 2, 'Active');
UPDATE enrollment SET enr_status = 'Dropped'
WHERE stu_num = 'S200' AND off_id = 2;

UPDATE enrollment
SET enr_status = 'Potato'
WHERE stu_num = 'S200' AND off_id = 2;

-- OUTPUT

-- SELECT * FROM enrollment;


-- SELECT * FROM enrollment_audit;


-- REFLECTION
-- Storing business rules directly inside the database ensures that
-- data remains correct and consistent no matter what application
-- or user interacts with it. Trigger-based validation centralizes
-- logic so errors are prevented at the source instead of being caught
-- later in the application.
