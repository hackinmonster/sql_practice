SELECT DISTINCT
    job_location,
    count(job_id) as job_count
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    job_location
ORDER BY
    job_count DESC

