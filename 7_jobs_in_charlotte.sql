SELECT
    job_title_short,
    count(job_id) as job_count
FROM
    job_postings_fact
WHERE
    job_location = 'Charlotte, NC'
GROUP BY
    job_title_short
ORDER BY
    job_count DESC
