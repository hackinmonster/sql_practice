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




