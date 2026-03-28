create table january_jobs as 
    select * 
    from job_postings_fact
    where extract(month from job_posted_date) = 1; 

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

select job_posted_date from march_jobs;

select *
from (
    select * from job_postings_fact
    where extract(month from job_posted_date) = 1
) as january_jobs;
