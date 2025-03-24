# SQL queries for cleaning
-- 1. Check for Missing Values 
--Identify NULL values in each column.
--Focus on critical fields like Patient ID, Encounter ID, Diagnosis, Procedure Code, etc.
USE hospital_patient_records;

SELECT * FROM procedures_table;

-- We need to set the start date and end date field to a DATETIME value, we first addedd new columns 'start_date_new. and converted start_date into a datetime value
ALTER TABLE procedures_table ADD COLUMN start_date_new DATETIME;

UPDATE procedures_table 
SET start_date_new = STR_TO_DATE(start_date, '%Y-%m-%dT%H:%i:%sZ');

-- Now we have to get rid of the colum 'start_date' so that we can change 'start_date-new' to start_date
ALTER TABLE procedures_table DROP COLUMN start_date;
ALTER TABLE procedures_table CHANGE COLUMN start_date_new start_date DATETIME;

-- Now we will do the same for end date.
ALTER TABLE procedures_table ADD COLUMN end_date_new DATETIME;

UPDATE procedures_table 
SET end_date_new = STR_TO_DATE(end_date, '%Y-%m-%dT%H:%i:%sZ');

ALTER TABLE procedures_table DROP COLUMN end_date;

ALTER TABLE procedures_table CHANGE COLUMN end_date_new end_date DATETIME;


-- We have to do the stem step of datetime for any other table that have datetime field. Another table in consideration is encounters table.
SELECT *  FROM encounters;

-- Create a new column start_time_new with empty fields so that we can replicate the starttime data into it
ALTER TABLE encounters ADD COLUMN start_time_new DATETIME;

-- Replicate the start_time data into the start_time_new
UPDATE encounters
SET start_time_new = STR_TO_DATE(start_time, '%Y-%m-%dT%H:%i:%sZ' );

-- Now we can drop the start time column so that we can rename the start_time_new to start_time
ALTER TABLE encounters
DROP COLUMN start_time;

ALTER TABLE encounters CHANGE COLUMN start_time_new start_time DATETIME;

-- Let us do same for the stop_time colum
 ALTER TABLE encounters ADD COLUMN stop_time_new DATETIME;

 -- Replicate the start_time data into the start_time_new
UPDATE encounters
SET stop_time_new = STR_TO_DATE(stop_time, '%Y-%m-%dT%H:%i:%sZ' );

-- Now we can drop the stop time column so that we can rename the stop_time_new to stop_time
ALTER TABLE encounters
DROP COLUMN stop_time;

ALTER TABLE encounters CHANGE COLUMN stop_time_new stop_time DATETIME;