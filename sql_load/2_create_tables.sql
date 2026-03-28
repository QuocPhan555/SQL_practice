-- Create company_dim table with primary key
CREATE TABLE public.company_dim
(
    company_id INT PRIMARY KEY,
    name TEXT,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

-- Create skills_dim table with primary key
CREATE TABLE public.skills_dim
(
    skill_id INT PRIMARY KEY,
    skills TEXT,
    type TEXT
);

-- Create job_postings_fact table with primary key
CREATE TABLE public.job_postings_fact
(
    job_id INT PRIMARY KEY,
    company_id INT,
    job_title_short VARCHAR(255),
    job_title TEXT,
    job_location TEXT,
    job_via TEXT,
    job_schedule_type TEXT,
    job_work_from_home BOOLEAN,
    search_location TEXT,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country TEXT,
    salary_rate TEXT,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC,
    FOREIGN KEY (company_id) REFERENCES public.company_dim (company_id)
);

-- Create skills_job_dim table with a composite primary key and foreign keys
CREATE TABLE public.skills_job_dim
(
    job_id INT,
    skill_id INT,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES public.job_postings_fact (job_id),
    FOREIGN KEY (skill_id) REFERENCES public.skills_dim (skill_id)
);

-- Set ownership of the tables to the postgres user
ALTER TABLE public.company_dim OWNER to postgres;
ALTER TABLE public.skills_dim OWNER to postgres;
ALTER TABLE public.job_postings_fact OWNER to postgres;
ALTER TABLE public.skills_job_dim OWNER to postgres;

-- Create indexes on foreign key columns for better performance
CREATE INDEX idx_company_id ON public.job_postings_fact (company_id);
CREATE INDEX idx_skill_id ON public.skills_job_dim (skill_id);
CREATE INDEX idx_job_id ON public.skills_job_dim (job_id);

select 
    job_title_short as title, 
    job_location as location,
    job_posted_date at time zone 'utc' at time zone 'est' as date_time,
    extract(month from  job_posted_date) as date_month
from job_postings_fact
limit 5;

select
    count(job_id) as job_count,
    extract(month from  job_posted_date) as month
from job_postings_fact
where job_title_short = 'Data Analyst'
GROUP BY month
ORDER BY job_count;

select * from job_postings_fact
limit 5; 

-- Practice 1
SELECT
    avg(salary_year_avg) as avg_year,
    avg(salary_hour_avg) as avg_hour,
    job_schedule_type,
   
from job_postings_fact
where job_posted_date > '2023-06-01'
GROUP BY  job_schedule_type;

-- Practice 2
select 
    count(job_id) as count_job,
    extract(month from job_posted_date) as month
from job_postings_fact
group by month
order by month;

-- Practice 3 
select 
    job_posted_date,
    company_dim.name  as name
from job_postings_fact
left join company_dim on job_postings_fact.company_id = company_dim.company_id
where job_health_insurance is TRUE 
    and extract(quarter from job_posted_date) = 2
    and extract(year from job_posted_date) = 2023

select 
    count(job_id) as number_job,
    case 
        when job_location = 'Anywhere' then 'Remote'
        when job_location = 'New York, NY' then 'Local'
        else 'Onsite'
    end as location_category
from job_postings_fact
where job_title_short ='Data Analyst'
group by location_category;

select 
    count(*) as jobs,  
    case
        when salary_year_avg > 80000 then 'High'
        when salary_year_avg between 50000 and 80000 then 'Standard'
        else 'Low'
    end as salary_range
from job_postings_fact
where job_title_short ='Data Analyst'
GROUP BY salary_range
ORDER BY salary_range desc
    
SELECT
    CASE
        WHEN salary_year_avg IS NULL                     THEN 'Not specified'
        WHEN salary_year_avg > 80000                     THEN 'High'
        WHEN salary_year_avg BETWEEN 50000 AND 80000     THEN 'Standard'
        ELSE 'Low'
    END AS salary_range,
    COUNT(*) AS nb_jobs
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY salary_range
ORDER BY nb_jobs DESC;
 
select * from job_postings_fact
where job_work_from_home = true
limit 10 ; 
select 
skills,
count(skill_id) from skills_dim
group by skills;

select 
    name as company_name,
    company_id
from company_dim
where company_id in (
        select 
            company_id 
        from job_postings_fact
        where job_no_degree_mention = true); 
select * from company_job_count;

-- PB1 2h42m
select
    skills
from skills_dim
where skill_id in (
    select 
    skill_id
    from skills_job_dim
    group by skill_id
    order by count(*) desc
    limit 5);

--PB2 2h42m 

select 
    company_id,
    job_count,
    case 
    when job_count > 50 then 'Large'
    when job_count between 10 and 50 then 'Medium'
    else 'Small'
    end as size_identify
from (
    select 
    company_id,
    count(*) as job_count
    from job_postings_fact
    group by  company_id);

-- PB 7 2H48M 
with remote_job_skill as (
    select 
        skill_id,
        count(*) as skill_count    
    from skills_job_dim as skill_to_job
    inner join job_postings_fact on job_postings_fact.job_id = skill_to_job.job_id
    where job_postings_fact.job_work_from_home = TRUE
    GROUP BY skill_id)

select 
    remote_job_skill.skill_id,
    skill_count,
    skills as skill_name
from remote_job_skill
inner join skills_dim on remote_job_skill.skill_id=skills_dim.skill_id 
order by skill_count desc 
limit 5;

select * from skills_dim;
select * from january_jobs;
select * from february_jobs;
select * from march_jobs;

select 
job_title_short,
company_id,
job_location
from january_jobs

union 
select 
job_title_short,
company_id,
job_location
from february_jobs;

with cor_skills as 
(select 
    skills,
    skills_dim.type,
    skill_id
from skills_dim)

select *
from cor_skills
;

-- PB8 2H55M 

select 
    q1_jobs.job_location,
    q1_jobs.job_title_short,
    q1_jobs.job_via,
    q1_jobs.job_posted_date::date
from(
select *
from january_jobs
UNION
select * from february_jobs
UNION
select * from march_jobs) as q1_jobs
;

