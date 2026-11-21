create database Medical_Data_Hub ;
use Medical_Data_Hub;

select * from admissions_data;
describe admissions_data;

ALTER TABLE admissions_data
MODIFY COLUMN admission_date DATE;

ALTER TABLE admissions_data
MODIFY COLUMN discharge_date DATE;

UPDATE patients
SET birth_date =
    CASE
        WHEN birth_date LIKE '%/%' THEN
            DATE_FORMAT(
                STR_TO_DATE(birth_date, '%m/%d/%Y'),
                '%Y-%m-%d'
            )
        WHEN birth_date LIKE '%-%' THEN
            DATE_FORMAT(
                STR_TO_DATE(birth_date, '%d-%m-%Y'),
                '%Y-%m-%d'
            )
    END;
ALTER TABLE patients
MODIFY COLUMN birth_date DATE;

-- 1.	Show first name, last name, and gender of patients whose gender is 'M'

select first_name,last_name,CONCAT(first_name, ' ', last_name) AS full_name, gender from patients
where gender='M';

-- 2.	Show first name and last name of patients who do not have allergies.

select first_name,last_name from patients
where  allergies is null ;

-- 3.	Show first name of patients that start with the letter 'C'
select * from patients
where first_name Like  'c%';

-- 4.	Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)
select first_name, last_name , weight from patients
where weight  between 100 and 120;

-- 5.	Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'
UPDATE patients
SET allergies = 'NKA'
WHERE allergies IS NULL;

-- 6.	Show first name and last name concatenated into one column to show their full name.
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM patients;

-- 7.	Show first name, last name, and the full province name of each patient.
select first_name,last_name,province_name from patients as p
 join proviance_names as pn on p.province_id=pn.province_id;


-- 	8.	Show how many patients have a birth_date with 2010 as the birth year.
select count(*) as patients, year(birth_date) as `year` from patients
where year(birth_date) in (2010)
group by year(birth_date) ;

-- 9.	Show the first_name, last_name, and height of the patient with the greatest height.
select first_name,last_name, height from patients
order by height desc
limit 1;

-- 10.	Show all columns for patients who have one of the following patient_ids: 1,45,534,879,1000
select*from patients
where patient_id in (1,45,534,879,1000);

-- 11.	Show the total number of admissions
select count(*) as no_of_total_patients from admissions_data;

-- 12.	Show all the columns from admissions where the patient was admitted and discharged on the same day.
SELECT ad.patient_id, p.first_name AS patient_first_name, p.last_name, ad.admission_date, ad.discharge_date, d.doctor_id, d.first_name AS doctor_first_name
FROM Admissions_Data AS ad
JOIN Patients AS p ON ad.patient_id = p.patient_id
JOIN Doctors AS d ON d.doctor_id = ad.attending_doctor_id
WHERE ad.admission_date = ad.discharge_date;

-- 13.	Show the total number of admissions for patient_id 579.
select patient_id, count(*)  as total_admissions from patients
where patient_id = 579
group by patient_id;

-- 14.	Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?
select distinct(p.city),count(*) as no_of_patients from patients as p join proviance_names as pn on p.province_id=pn.province_id
where p. province_id ='NS'
group by p.city;

-- 15.	Write a query to find the first_name, last name and birth date of patients who have height more than 160 and weight more than 70
select first_name, last_name,height,weight , birth_date from patients
where height > 160 and weight > 70;

-- 16.	Show unique birth years from patients and order them by ascending

SELECT DISTINCT(birth_date) AS birth_year FROM patients
ORDER BY birth_year ASC;

-- 17.	Show unique first names from the patients table which only occurs once in the list.
select first_name,count(first_name) as counts from patients
group by first_name
having count(first_name)=1 ;

-- 18.	Write a query to find patients who have been admitted more than once. Show:
SELECT p.patient_id, p.first_name, p.last_name, COUNT(ad.patient_id) AS total_admission FROM patients AS p
JOIN admissions_data AS ad ON p.patient_id = ad.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING COUNT(ad.patient_id) > 1;

-- 19.Find the most frequent diagnosis in the admissions table and how many times it appears.
select diagnosis , count(*) as total_count from admissions_data
group by diagnosis
order by diagnosis desc
limit 1;

-- 20.	List all doctors who have never attended any patient
select  doctor_id,first_name,last_name from doctors d left join admissions_data ad on d.doctor_id = ad.attending_doctor_id
WHERE d.doctor_id IS NULL;

-- 21.	Calculate the average hospital stay (in days) for all admissions.
SELECT AVG(DATEDIFF(discharge_date, admission_date)) AS AVG_LEN_STAY
FROM admissions_data
WHERE YEAR(discharge_date) <> 1971;

-- 22.	Show the number of patients in each province.
SELECT pn.province_name, COUNT(p.patient_id) AS total_patients FROM patients AS p
JOIN proviance_names AS pn ON p.province_id = pn.province_id
GROUP BY pn.province_name;

-- 23.	Find the top 3 doctors who handled the most admissions. Show:
-- 	•  doctor full name 
-- 	•  number of admission

WITH Doctor_admission AS
(
    SELECT
        AD.attending_doctor_id,
        CONCAT(D.first_name, ' ', D.last_name) AS full_name,
        COUNT(AD.patient_id) AS no_of_admi
    FROM Doctors D
    JOIN Admissions_Data AD
        ON D.doctor_id = AD.attending_doctor_id
    GROUP BY
        AD.attending_doctor_id,
        D.first_name,
        D.last_name
),

Doctors_ranks AS
(
    SELECT
        attending_doctor_id,
        full_name,
        no_of_admi,
        DENSE_RANK() OVER (
            ORDER BY no_of_admi DESC
        ) AS ranks
    FROM Doctor_admission
)

SELECT
    attending_doctor_id,
    full_name,
    no_of_admi
FROM Doctors_ranks
WHERE ranks <= 3;

-- 24.	Find the admission record with the longest stay. Show:
-- ▪	•  patient_id 
-- ▪	•  admission & discharge dates 
-- ▪	•  total stay duration
SELECT patient_id, admission_date, discharge_date, DATEDIFF(discharge_date, admission_date) AS total_stay_days
FROM admissions_data
WHERE YEAR(discharge_date) <> 1971
ORDER BY total_stay_days DESC
LIMIT 1;-

-- 25.	Count how many doctors belong to each specialty.
select  specialty,count(*)as total_doctors from doctors
group by specialty;

-- 26.	Show how many admissions occurred each year.
SELECT YEAR(admission_date) AS admission_year, COUNT(*) AS total_admissions FROM admissions_data
GROUP BY YEAR(admission_date)
ORDER BY admission_year ASC;


-- 27.	List patients whose height is above the average height of all patients.
SELECT patient_id, first_name, last_name, height FROM patients
WHERE height > ( SELECT AVG(height) FROM patients);

-- 28.	Find patients who were admitted again within 30 days of a previous discharge.
SELECT ad1.patient_id, ad1.admission_date, ad1.discharge_date, ad2.admission_date AS re_admission_date, DATEDIFF(ad2.admission_date, ad1.discharge_date) AS days
FROM admissions_data AS ad1 JOIN admissions_data AS ad2 ON ad1.patient_id = ad2.patient_id
WHERE ad2.admission_date > ad1.discharge_date
AND DATEDIFF(ad2.admission_date, ad1.discharge_date)
BETWEEN 1 AND 30;

-- 29 List all patients who have never been admitted.
SELECT p.patient_id, p.first_name, p.last_name FROM patients AS p LEFT JOIN admissions_data AS ad
ON p.patient_id = ad.patient_id
WHERE ad.patient_id IS NULL;


WITH Doctor_admission AS
(
    SELECT
        AD.attending_doctor_id,
        CONCAT(D.first_name, ' ', D.last_name) AS full_name,
        COUNT(AD.patient_id) AS no_of_admi
    FROM Doctors D
    JOIN Admissions_Data AD
        ON D.doctor_id = AD.attending_doctor_id
    GROUP BY
        AD.attending_doctor_id,
        D.first_name,
        D.last_name
),

