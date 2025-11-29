Primary Keys
For our design, we decided to go with natural primary keys for all tables because the data we were given in the CSVs already included unique identifiers that made sense in the real world.
 We didn’t see a reason to generate artificial IDs since each table had something that was already unique and meaningful.
Natural PKs we used:
course_code – e.g. COMP1510
term_code – e.g. 202530
student_set – e.g. SETD
student – uses student_id (like A001)
lab_section – uses lab_section_id (like L01)
lab_assignment – uses la_assignment_id (like LAB01)
lab_event – uses le_id (like L01-L01)
user_account, progress, and progress_change_log also use text-based IDs that are unique.

Foreign Keys & Relationships
We made sure every relationship matched the business rules:
Students must belong to a Set, and the student_set_code can’t be null.
 If a set code changes, it cascades to all students (ON UPDATE CASCADE).
Lab Sections link to a Course, Term, and Set. All of those are required and set to cascade on update too.
Lab Events belong to a Lab Section, and we used a composite foreign key (le_section_id, course_code, term_code) to make sure the event always matches the correct section, course, and term. We also added ON DELETE CASCADE so deleting a section deletes its events automatically.
Student_Section connects students to lab sections, and if a section gets deleted, the link goes with it.
Progress connects a student to a lab event. Deleting an event now also deletes any related progress (we used ON DELETE CASCADE for that).
Progress Change Log connects to both progress and user_account. Deleting a progress record removes its log, but deleting a user is blocked to protect the audit trail.

Uniqueness & Constraints
Student emails must be unique (no duplicate addresses).
Each combination of (lab_section_id, lab_course_code, lab_term_code) is unique to prevent mix-ups between sections.
Term codes must follow the six-digit format (CHECK (term_code ~ '^[0-9]{6}$')).
Course credits must be between 1 and 9.
lab_event checks that le_ends_at is after le_starts_at.
progress checks that pgr_polished_submitted_at is after pgr_inlab_submitted_at when both are present.
Boolean fields like pgr_prepared and pgr_late default to FALSE.

Cascading Logic
We used cascading only when it made logical sense:
Deleting a lab_section removes its lab_events, which also removes any related progress and change logs automatically.
For tables like user_account, we kept delete restricted so we don’t lose audit history.

Naming Conventions
We used prefixes to make joins easier and keep things organized.
 For example:
le_ for lab_event columns,
pgr_ for progress,
chl_ for progress_change_log.
Also, every constraint is named properly (pk_, fk_, ck_, uq_) so if there’s an error, it’s obvious where it came from.
