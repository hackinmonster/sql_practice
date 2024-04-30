
CREATE TABLE job_applied (
    job_id INT,
    application_sent_datae DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);

INSERT INTO job_applied
            (job_id,
            application_sent_datae,
            custom_resume,
            resume_file_name,
            cover_letter_sent,
            cover_letter_file_name,
            status)
VALUES
            (1,
            '2024-02-01',
            true,
            'resume_01.pdf',
            true,
            'cover_letter_01.pdf',
            'submitted');

SELECT *
FROM job_applied;

ALTER TABLE job_applied
ADD contact VARCHAR(50);


UPDATE job_applied
SET    contact = 'Erlich Bachman'
WHERE  job_id = 1

ALTER TABLE job_applied
RENAME COLUMN contact TO contact_name;


ALTER TABLE job_applied
ALTER COLUMN contact_name TYPE text;

ALTER TABLE job_applied
DROP column contact_name;

DROP TABLE job_applied;

SELECT *
FROM job_postings_fact
LIMIT 100;''

SELECT 
    '2023-02-19'::DATE,
    '123'::INTEGER,
    'true'::BOOLEAN,
    '3.14'::REAL;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AS date
FROM
    job_postings_fact;

--converting timestamp to date

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date::DATE AS date
FROM
    job_postings_fact
LIMIT 100;

--converting timezone

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
FROM
    job_postings_fact
LIMIT 100;

--extracting month,year

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST',
    EXTRACT(MONTH FROM job_posted_date) as date_month,
    EXTRACT(YEAR FROM job_posted_date) as date_year

FROM
    job_postings_fact
LIMIT 100; 

SELECT
    job_id,
    EXTRACT(MONTH from job_posted_date) AS month
FROM
    job_postings_fact
LIMIT 5;

SELECT
    COUNT(job_id) as job_posted_count,
    EXTRACT(MONTH from job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
ORDER BYv
    job_posted_count DESC;

SELECT 
    job_schedule_type,
    AVG(salary_year_avg)
FROM 
    job_postings_fact
WHERE
    job_posted_date > '6/1/2023'
GROUP BY
    job_schedule_type;


SELECT
    count(job_id) AS job_count,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
) AS month
FROM
    job_postings_fact
GROUP BY
    month
ORDER BY
    month ASC;



SELECT DISTINCT
    companies.name,
    job_health_insurance,
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date) AS month

FROM
    company_dim AS companies
LEFT JOIN job_postings_fact
    ON companies.company_id = job_postings_fact.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE AND
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date) > 3 AND
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date) < 7
LIMIT 100;

-- January
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 3;


DROP TABLE january_jobs;
DROP TABLE february_jobs;
DROP TABLE march_jobs;

SELECT job_posted_date
FROM march_jobs;

SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'Charlotte, NC' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category

FROM job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;



SELECT
    CASE
        WHEN salary_year_avg < 50000 THEN 'Low Salary'
        WHEN salary_year_avg > 100000 THEN 'High Salary'
        ELSE 'Standard Salary'
    END AS salary,
    salary_year_avg
    
FROM job_postings_fact

WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 500;


--subquery
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH from job_posted_date) = 1
) AS january_jobs;

--cte (common table expressions)
WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)
SELECT *
FROM january_jobs;


--subquery example
SELECT 
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
    ORDER BY
        company_id
)

--cte example

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT 
    company_dim.name AS company_name,
    total_jobs

FROM 
    company_dim
LEFT JOIN company_job_count
    ON company_job_count.company_id = company_dim.company_id
ORDER BY
    total_jobs DESC;


SELECT
    company_dim.name,
    CASE
        WHEN total_jobs < 10 THEN 'Small'
        WHEN total_jobs >= 10 OR total_jobs <= 50 THEN 'Medium'
        WHEN total_jobs > 50 THEN 'Large'
    END AS company_size
FROM (
    SELECT
        company_id,
        COUNT(company_id) AS total_jobs
    FROM job_postings_fact
    GROUP BY company_id
) AS job_counts
LEFT JOIN company_dim ON
    company_dim.company_id = job_counts.company_id;


WITH remote_job_skills AS (
SELECT 
    skill_id,
    COUNT(*) AS skill_count
FROM
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON
    job_postings.job_id = skills_to_job.job_id
WHERE
    job_postings.job_work_from_home = True AND
    job_title_short = 'Data Analyst'
GROUP BY
    skill_id
)
SELECT *
FROM remote_job_skills
INNER JOIN skills_dim AS skills 
    ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;

--unions


SELECT 
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT 
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL

SELECT 
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs


--job postings time in first quarter
--job postings salary > 70k
--skill and skill type for each job


WITH q1_jobs AS (

SELECT
    january_jobs.job_id,
    job_title_short,
    salary_year_avg
FROM 
    january_jobs

UNION ALL

SELECT
    february_jobs.job_id,
    job_title_short,
    salary_year_avg
FROM 
    february_jobs

UNION ALL

SELECT
    march_jobs.job_id,
    job_title_short,
    salary_year_avg
FROM 
    march_jobs
)

SELECT 
    q1_jobs.job_id,
    job_title_short,
    salary_year_avg,
    skills_dim.skills
FROM
    q1_jobs

LEFT JOIN skills_job_dim ON
    q1_jobs.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON
    skills_job_dim.skill_id = skills_dim.skill_id

WHERE 
    salary_year_avg > 70000
ORDER BY
    salary_year_avg ASC;












