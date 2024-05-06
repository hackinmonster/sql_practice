/*
patients table

patient_id	INT
first_name	TEXT
last_name	TEXT
gender	CHAR(1)
birth_date	DATE
city	TEXT
primary key icon	province_id	CHAR(2)
allergies	TEXT
height	INT
weight	INT
*/

/*
1) Show all of the patients grouped into weight groups.
Show the total amount of patients in each weight group.
Order the list by the weight group decending.
For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.
*/

select
	count(patient_id) as patients_in_group,
    floor(weight / 10) * 10 AS weight_group
from
	patients
group by
	weight_group
order by 
	weight_group DESC

/*
2) Show patient_id, weight, height, isObese from the patients table.
Display isObese as a boolean 0 or 1.
Obese is defined as weight(kg)/(height(m)2) >= 30.
weight is in units kg.
height is in units cm.
*/

SELECT
    patient_id,
    weight,
    height,
    (CASE
        WHEN (weight / POWER((CAST(height AS FLOAT) / 100), 2)) < 30 THEN 0
        WHEN (weight / POWER((CAST(height AS FLOAT) / 100), 2)) >= 30 THEN 1
    END) AS isObese
FROM
    patients;

/*
3) Show patient_id, first_name, last_name, and attending doctor's specialty.
Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
Check patients, admissions, and doctors tables for required information.
*/

select
	patients.patient_id,
    patients.first_name,
    patients.last_name,
    doctors.specialty
From patients
left join admissions ON patients.patient_id = admissions.patient_id
LEFT JOIN doctors ON doctors.doctor_id = admissions.attending_doctor_id
where
	diagnosis LIKE ("%Epilepsy%") AND
    doctors.first_name = "Lisa"

/*
4) All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
The password must be the following, in order:
patient_id
the numerical length of patient's last_name
year of patient's birth_date
*/

select distinct
	patients.patient_id,
    concat(admissions.patient_id, len(patients.last_name), year(patients.birth_date)) AS temp_password
from	
	admissions
left join patients on admissions.patient_id = patients.patient_id

/*
5) Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
*/

with has_insurance as (

select
    (case
    when (patient_id % 2 == 0) THEN 'Yes'
    ELSE 'No'
    END) as has_insurance
from
	admissions
) 
select
	has_insurance,
    ((case
     when has_insurance = 'Yes' THEN 10
     ELSE 50
     end) * count(has_insurance)) as total_cost   
from	
	has_insurance
group by
	has_insurance





