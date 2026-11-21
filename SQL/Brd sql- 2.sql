-- 1.	Show patient_id and first_name from patients where their first_name starts and ends with 's' and is at least 6 characters long.
SELECT  patient_id, first_name FROM patients
WHERE first_name LIKE 's%s'
AND LENGTH(first_name) <= 6;

-- 2.	Show patient_id, first_name, last_name from patients whose diagnosis is 'Dementia'. Primary diagnosis is stored in the admissions table.
SELECT p.patient_id, p.first_name, p.last_name FROM patients p INNER JOIN admissions_data a
ON p.patient_id = a.patient_id
WHERE a.diagnosis = 'Dementia';

-- 3.	Display every patient's first_name. Order the list by the length of each name and then by alphabetically.
SELECT  patient_id, first_name,length(first_name) FROM patients
ORDER BY  first_name ASC;

-- 4.	Show the total number of male patients and the total number of female patients in the patients table. Display the two results in the same row.
SELECT
    SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS Male_Patients,
    SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS Female_Patients
FROM patients;

-- 5.	Show the total number of male patients and the total number of female patients in the patients table. Display the two results in the same row.
SELECT patient_id, diagnosis, COUNT(*) AS admission_count
FROM admissions_data
GROUP BY patient_id, diagnosis
HAVING COUNT(*) > 1;

-- 6.	Show the city and the total number of patients in the city. Order from most to least patients and then by city name ascending.
SELECT city, COUNT(patient_id) AS total_patients FROM patients
GROUP BY city
ORDER BY total_patients DESC, city ASC;

-- 7.	Show first name, last name and role of every person that is either patient or doctor. The roles are either "Patient" or "Doctor"
SELECT first_name, last_name, 'Patient' AS role
FROM patients
UNION ALL
SELECT first_name, last_name, 'Doctor' AS role
FROM doctors;

-- 8.	Show all allergies ordered by popularity. Remove NULL values from the query.
SELECT allergies, COUNT(*) AS total_patients FROM patients
WHERE allergies IS NOT NULL
GROUP BY allergies
ORDER BY total_patients DESC;

-- 9.	Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
SELECT first_name, last_name, birth_date FROM patients
WHERE YEAR(birth_date) BETWEEN 1970 AND 1979
ORDER BY birth_date ASC;

-- 10.	We want to display each patient's full name in a single column. Their last_name in all uppercase letters must appear first, then first_name in all
--  lowercase letters. Separate the last_name and first_name with a comma. Order the list by the first_name in descending order. EX: SMITH, Jane
SELECT CONCAT(UPPER(last_name), ', ', LOWER(first_name)) AS full_name
FROM patients
ORDER BY first_name DESC;

-- 11.	Show the province_id(s), sum of height where the total sum of its patients' height is greater than or equal to 7,000.
SELECT province_id, SUM(height) AS total_height
FROM patients
GROUP BY province_id
HAVING SUM(height) >= 7000;
-- 12.	Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'
SELECT
    MAX(weight) - MIN(weight) AS weight_difference
FROM patients
WHERE last_name = 'Maroni';

-- 13.	Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with the most admissions to the least admissions.
SELECT day(admission_date) as days,count(*) as Total_patients
FROM admissions_data
GROUP BY DAY(admission_date)
ORDER BY Total_patients DESC;

-- 14.	Show all of the patients grouped into weight groups. Show the total number of patients in each weight group. Order the list by the weight group descending. 
-- e.g. if they weigh 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.

SELECT FLOOR(weight / 10) * 10 AS Weight_group, COUNT(*) AS total_patients FROM patients
GROUP BY FLOOR(weight / 10) * 10
ORDER BY Weight_group DESC;

-- 15.	Show patient_id, weight, height, isObese from the patients table. Display isObese as a
--  boolean 0 or 1. Obese is defined as weight(kg)/(height(m). Weight is in units kg. Height is in units cm.
SELECT
    patient_id,
    weight,
    height,
    ROUND(weight / POWER(height / 100.0, 2), 2) AS BMI,
    CASE
        WHEN weight / POWER(height / 100.0, 2) >= 30 THEN 1
        ELSE 0
    END AS isObese
FROM patients;

-- 16.	Show patient_id, first_name, last_name, and attending doctor's specialty. Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's 
-- first name is 'Lisa'. Check patients, admissions, and doctors tables for required information.

select ad.patient_id,p.first_name,p.last_name,d.first_name,specialty from admissions_data ad join doctors d 
on ad.attending_doctor_id = d.doctor_id join patients p 
on p.patient_id=ad.patient_id
where diagnosis = 'Epilepsy' 
and 
d.first_name like '%lisa%';


-- 17.	All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
-- The password must be the following, in order:
-- 	patient_id
-- 	the numerical length of patient's last_name
-- 	year of patient's birth_date

	SELECT DISTINCT
    p.patient_id,
    LENGTH(p.last_name) AS last_name_length,
    YEAR(p.birth_date) AS birth_year,
    CONCAT(
        p.patient_id, '-',
        LENGTH(p.last_name), '-',
        YEAR(p.birth_date)
    ) AS temp_password
FROM patients p
JOIN admissions_data ad
    ON p.patient_id = ad.patient_id;