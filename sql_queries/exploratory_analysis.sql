# Queries for EDA

-- 1. We want to analyze patient demographics to understand:
-- (ii) Gender Distribution – What is the gender breakdown of patients?
-- (iii) Geographical Distribution – Which locations have the highest number of patients?

SELECT * FROM patients;

-- Total Number of male and female patients 
SELECT gender, COUNT(*) AS gender_count
FROM patients
GROUP BY gender;

-- Find out the city with the highest number of patients and their corressponding death rate
SELECT city, COUNT(*) AS city_with_highest_patient,  
COUNT(YEAR(deathdate)) AS death_rate
FROM patients
GROUP BY city 
ORDER BY city_with_highest_patient DESC;

-- How many of the deaths were men and women respectively
SELECT 
    city, 
    gender, 
    COUNT(patient_id) AS total_patients, 
    COUNT (YEAR(deathdate)) AS death_rate
FROM patients
WHERE deathdate IS NOT NULL
GROUP BY city, gender
ORDER BY total_patients DESC;


-- there is no column for age, therefore, we have to add age column
SELECT 
    patient_id, 
    birthdate, 
    TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age 
FROM patients;

-- Let us find out the age of the youngest and oldest patients
SELECT MAX(age) AS oldest_patient, MIN(age) AS youngest_patient 
FROM patients;


-- (i) Age Distribution – What is the age range of patients, and which age group is most common? 
SELECT * FROM (SELECT
    CASE 
        WHEN age BETWEEN 33 and 50 THEN '33 - 50'
        WHEN age BETWEEN 50 and 65 THEN '50 - 65'
        WHEN age BETWEEN 65 and 80 THEN '65 - 80'
        WHEN age BETWEEN 80 and 103 THEN '80 - 103'
    END AS age_bracket,
     CASE 
        WHEN age BETWEEN 33 and 50 THEN 'young adults'
        WHEN age BETWEEN 50 and 65 THEN 'adults'
        WHEN age BETWEEN 65 and 80 THEN 'old'
    ELSE 'old age'
END AS age_category
FROM patients) AS age_group
GROUP BY age_bracket, age_category;

-- Let us find out the category that has the highest age group
SELECT age_bracket, age_category, COUNT(*) AS count
 FROM 
 (SELECT
    CASE 
        WHEN age BETWEEN 33 and 50 THEN '33 - 50'
        WHEN age BETWEEN 50 and 65 THEN '50 - 65'
        WHEN age BETWEEN 65 and 80 THEN '65 - 80'
        WHEN age BETWEEN 80 and 103 THEN '80 - 103'
    END AS age_bracket,
     CASE 
        WHEN age BETWEEN 33 and 50 THEN 'young adults'
        WHEN age BETWEEN 50 and 65 THEN 'adults'
        WHEN age BETWEEN 65 and 80 THEN 'old'
    ELSE 'old age'
END AS age_category
FROM patients) AS age_group
GROUP BY age_bracket, age_category;

-- 2. Find the most frequently performed procedures – 
-- (I) Sort by frequency – Rank them from the most common to the least.
SELECT * FROM procedures_table;

-- Count how many times each procedure appears in the procedures table.
SELECT procedure_code, description, COUNT(*) AS frequency
FROM procedures_table
GROUP BY procedure_code, description
ORDER BY frequency DESC;

-- Filter by Timeframe (e.g., Yearly Analysis)

SELECT procedure_code, description, COUNT(*) AS procedure_count,
YEAR(start_date) AS year_performed
FROM procedures_table
GROUP BY procedure_code, description, YEAR(start_date) 
ORDER BY procedure_count DESC;


-- Identify the most common procedures for males vs. females
SELECT gender AS sex, description AS reason, COUNT(description) AS procedure_count
FROM patients p JOIN procedures_table proc ON p.patient_id = proc.PATIENT 
GROUP BY gender, description
ORDER BY procedure_count DESC;

-- 3. Let us Explore the Ecounters Table
SELECT encounterclass FROM encounters;

-- Most Common Encounter Types: What are the most frequently recorded types of patient encounters?
SELECT description,reasondescription, COUNT(encounterclass) AS num_encounters
FROM encounters
GROUP BY description, reasondescription, encounterclass
ORDER BY num_encounters DESC;

-- Monthly/Yearly Trends in Patient Visits: How do patient encounters fluctuate over time (monthly, quarterly, or yearly)?
SELECT encounterclass, reasondescription, COUNT(*) AS num_encounters,
YEAR(start_time) AS year_of_encounter
FROM encounters
GROUP BY reasondescription, encounterclass, year_of_encounter
ORDER BY num_encounters DESC;

-- Average Length of Stay for Patients: What is the average duration of patient visits? (Only if start_date and end_date exist)
SELECT AVG(TIMESTAMPDIFF(DAY, start_time, stop_time)) AS avg_length_of_stay
FROM encounters
WHERE start_time IS NOT NULL AND stop_time IS NOT NULL;

--Readmission Rate Analysis: How many patients have multiple encounters within a short period (e.g., 30 days)? 
WITH patient_readmission AS 
(
     SELECT encounters_id, patient, 
     encounterclass, 
     reasondescription,
     start_time,
     LAG(stop_time) OVER(PARTITION BY patient ORDER BY start_time) AS previous_discharge_date
     FROM encounters),
filteredreadmissions AS
 (
    SELECT *,
    DATEDIFF(start_time, previous_discharge_date) AS days_between 
    FROM patient_readmission
WHERE previous_discharge_date IS NOT NULL 
AND DATEDIFF(start_time, previous_discharge_date) <= 30
),
organizationStat AS 
 (
    SELECT 
 encounters_id, COUNT(patient) AS readmission_count
 FROM filteredreadmissions
 GROUP BY encounters_id
 )
 SELECT encounters_id, readmission_count,
       RANK() OVER (ORDER BY readmission_count DESC) AS rank_by_readmissions
FROM organizationStat;

-- Most Common Payers
--Objective: Identify the most frequently used insurance providers or payment methods.
SELECT * from payers;

SELECT * FROM encounters;
DESCRIBE payers;

-- Identify the most frequently used insurance providers or payment methods.
SELECT payer AS payer, name AS name, COUNT(*) AS count_ins_provider
FROM encounters e JOIN payers p
ON e.payer = p. Id
GROUP BY payer, name
HAVING name  != 'NO_INSURANCE'
ORDER BY count_ins_provider DESC;


-- Average Cost per Payer
-- Objective: Calculate the average amount paid per payer.

SELECT p.name, ROUND(AVG(payer_coverage),2) AS avg_cost
FROM encounters e JOIN payers p
ON e.payer = p.id
WHERE payer_coverage > 0
GROUP BY p.name;


---- Trend Analysis of Payments Over Time
-- Objective: Examine how payments from different payers change over months or years.
-- Calculate the Year-over-Year (YoY) percentage change in average cost for each payer.
WITH payer_cost_trend AS
(
SELECT 
    p.name AS payer, 
    YEAR(e.start_time) AS year, 
    ROUND(AVG(e.payer_coverage), 2) AS avg_cost,
    LAG(ROUND(AVG(e.payer_coverage), 2)) OVER(PARTITION BY p.name ORDER BY YEAR(e.start_time)) AS previous_year_cost
FROM encounters e 
JOIN payers p ON e.payer = p.id
WHERE e.payer_coverage > 0
GROUP BY p.name, YEAR(e.start_time)
)
SELECT
    payer,
    year,
    avg_cost,
    previous_year_cost,
    ROUND(((avg_cost - previous_year_cost) / previous_year_cost) * 100, 2) AS YoY_change
FROM payer_cost_trend
ORDER BY year;


