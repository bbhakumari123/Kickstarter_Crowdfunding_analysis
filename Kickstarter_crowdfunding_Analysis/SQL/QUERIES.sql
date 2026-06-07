

use KICKSTARTER_CROWDFUNDING;


-- Q1
-- Convert the Date fields to Natural Time 
SELECT
    ProjectID,
    DATE(FROM_UNIXTIME(created_at)) AS created_at,
    DATE(FROM_UNIXTIME(deadline)) AS deadline,
    DATE(FROM_UNIXTIME(launched_at)) AS launched_at,
    DATE(FROM_UNIXTIME(updated_at)) AS updated_at,
    DATE(FROM_UNIXTIME(state_changed_at)) AS state_changed_at,
    DATE(FROM_UNIXTIME(successful_at)) AS successful_at
FROM projects;



ALTER TABLE projects
ADD COLUMN created_date DATE,
ADD COLUMN deadline_date DATE,
ADD COLUMN launched_date DATE,
ADD COLUMN updated_date DATE,
ADD COLUMN state_changed_date DATE,
ADD COLUMN successful_date DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE projects
SET
    created_date = DATE(FROM_UNIXTIME(created_at)),
    deadline_date = DATE(FROM_UNIXTIME(deadline)),
    launched_date = DATE(FROM_UNIXTIME(launched_at)),
    updated_date = DATE(FROM_UNIXTIME(updated_at)),
    state_changed_date = DATE(FROM_UNIXTIME(state_changed_at)),
    successful_date = CASE
        WHEN successful_at = 0 THEN NULL
        ELSE DATE(FROM_UNIXTIME(successful_at))
    END;
SET SQL_SAFE_UPDATES = 1;

-- ALTER TABLE crowdfunding_projects_1
-- DROP COLUMN created_at,
-- DROP COLUMN deadline,
-- DROP COLUMN launched_at,
-- DROP COLUMN updated_at,
-- DROP COLUMN state_changed_at,
-- DROP COLUMN successful_at;




 DROP TABLE IF EXISTS calendar;

-- SELECT COUNT(*) FROM crowdfunding_projects_1;


-- Q2
-- creating calender table
CREATE TABLE calendar (
    dt DATE PRIMARY KEY,
    year_col INT,
    monthno INT,
    monthfullname VARCHAR(20),
    quarter_col VARCHAR(2),
    yearmonth VARCHAR(10),
    weekdayno INT,
    weekdayname VARCHAR(20),
    financialmonth VARCHAR(5),
    financial_quarter VARCHAR(5)
);

SET @@cte_max_recursion_depth = 100000;

INSERT INTO calendar (
    dt,
    year_col,
    monthno,
    monthfullname,
    quarter_col,
    yearmonth,
    weekdayno,
    weekdayname,
    financialmonth,
    financial_quarter
)
WITH RECURSIVE date_series AS (
    SELECT MIN(created_date) AS dt
    FROM projects
    
    UNION ALL
    
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM date_series
    WHERE dt < (SELECT MAX(created_date) FROM projects)
)
SELECT
    dt,
    YEAR(dt),
    MONTH(dt),
    MONTHNAME(dt),
    CONCAT('Q', QUARTER(dt)),
    DATE_FORMAT(dt, '%Y-%b'),
    WEEKDAY(dt) + 1,
    DAYNAME(dt),
    CONCAT('FM',
        CASE
            WHEN MONTH(dt) >= 4 THEN MONTH(dt) - 3
            ELSE MONTH(dt) + 9
        END
    ),
    CONCAT('FQ-',
        CEIL(
            (
                CASE
                    WHEN MONTH(dt) >= 4 THEN MONTH(dt) - 3
                    ELSE MONTH(dt) + 9
                END
            ) / 3
        )
    )
FROM date_series;

SELECT * FROM calendar;

-- SELECT
   -- MIN(created_date) AS min_date,
    -- MAX(created_date) AS max_date
-- FROM crowdfunding_projects_1;

-- Q3
-- creating relationship
SELECT
    p.ProjectID,
    p.name AS project_name,
    p.state,
    c.name AS category_name,
    l.displayable_name AS location_name,
    cal.year_col,
    cal.monthfullname,
    cal.quarter_col,
    p.goal,
    p.usd_pledged,
    p.backers_count
FROM projects p
LEFT JOIN crowdfunding_category c
    ON p.category_id = c.id
LEFT JOIN crowdfunding_location l
    ON p.location_id = l.id
LEFT JOIN calendar cal
    ON p.created_date = cal.dt
LIMIT 20;

-- Q4
-- Goal amount into USD using the Static USD Rate
SELECT
    ProjectID,
    name,
    goal,
    static_usd_rate,
    goal * static_usd_rate AS goal_usd
FROM projects;


-- q5
-- Total Number of Projects based on Outcome
SELECT 
    state,
    COUNT(*) AS total_projects
FROM projects
GROUP BY state;

-- Total Number of Projects based on Location
SELECT 
    l.displayable_name AS location_name,
    COUNT(*) AS total_projects
FROM projects p
LEFT JOIN crowdfunding_location l
    ON p.location_id = l.id
GROUP BY l.displayable_name
ORDER BY total_projects DESC;

-- Total Number of Projects based on Category
SELECT 
    c.name AS category_name,
    COUNT(*) AS total_projects
FROM crowdfunding_projects_1 p
LEFT JOIN crowdfunding_category c
    ON p.category_id = c.id
GROUP BY c.name
ORDER BY total_projects DESC;

-- Total Projects by Year, Quarter, Month
SELECT 
    cal.year_col,
    cal.quarter_col,
    cal.monthfullname,
    COUNT(p.ProjectID) AS total_projects
FROM projects p
LEFT JOIN calendar cal
    ON p.created_date = cal.dt
GROUP BY 
    cal.year_col,
    cal.quarter_col,
    cal.monthno,
    cal.monthfullname
ORDER BY 
    cal.year_col,
    cal.monthno;
    
-- q6
--  Total Successful Projects ,Amount Raised,Number of Backers,and Avg NUmber of Days for successful projects

SELECT 
    COUNT(CASE WHEN state = 'successful' THEN 1 END) AS successful_projects,
    SUM(CASE WHEN state = 'successful' THEN usd_pledged ELSE 0 END) AS total_amount_raised,
    SUM(CASE WHEN state = 'successful' THEN backers_count ELSE 0 END) AS total_backers,
    AVG(CASE 
        WHEN state = 'successful' 
        THEN DATEDIFF(deadline_date, launched_date) 
    END) AS avg_days
FROM projects;

-- q7
-- Top Successful Projects based on Number of Backers
SELECT
    ProjectID,
    name AS project_name,
    backers_count
FROM projects
WHERE state = 'successful'
ORDER BY backers_count DESC
LIMIT 10;

-- Top Successful Projects based on Amount Raised
SELECT
    ProjectID,
    name AS project_name,
    usd_pledged AS amount_raised_usd
FROM projects
WHERE state = 'successful'
ORDER BY usd_pledged DESC
LIMIT 10;

-- q8
-- Percentage of Successful Projects Overall
SELECT
    ROUND(
        (COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS success_percentage_overall
FROM projects;

-- Percentage of Successful Projects by Category
SELECT
    c.name AS category_name,
    ROUND(
        (COUNT(CASE WHEN p.state = 'successful' THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS success_percentage
FROM projects p
LEFT JOIN crowdfunding_category c
    ON p.category_id = c.id
GROUP BY
    c.name
ORDER BY success_percentage DESC;

-- Percentage of Successful Projects by Year and Month
SELECT
    cal.year_col,
    cal.monthno,
    cal.monthfullname,
    ROUND(
        (COUNT(CASE WHEN p.state = 'successful' THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS success_percentage
FROM projects p
LEFT JOIN calendar cal
    ON p.created_date = cal.dt
GROUP BY
    cal.year_col,
    cal.monthno,
    cal.monthfullname
ORDER BY
    cal.year_col,
    cal.monthno;
  
  -- Percentage of Successful Projects by Year and Quarter
SELECT
    cal.year_col,
    cal.quarter_col,
    ROUND(
        (COUNT(CASE WHEN p.state = 'successful' THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS success_percentage
FROM projects p
LEFT JOIN calendar cal
    ON p.created_date = cal.dt
GROUP BY
    cal.year_col,
    cal.quarter_col
ORDER BY
    cal.year_col,
    cal.quarter_col;
 
 -- Percentage of Successful Projects by Goal Range
SELECT
    goal_range,
    ROUND(
        (COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS success_percentage
FROM (
    SELECT
        state,
        CASE
            WHEN goal < 1000 THEN 'Below 1K'
            WHEN goal >= 1000 AND goal < 10000 THEN '1K-10K'
            WHEN goal >= 10000 AND goal < 50000 THEN '10K-50K'
            WHEN goal >= 50000 AND goal < 100000 THEN '50K-100K'
            ELSE '100K+'
        END AS goal_range
    FROM projects
) AS x
GROUP BY
    goal_range
ORDER BY
    CASE
        WHEN goal_range = 'Below 1K' THEN 1
        WHEN goal_range = '1K-10K' THEN 2
        WHEN goal_range = '10K-50K' THEN 3
        WHEN goal_range = '50K-100K' THEN 4
        WHEN goal_range = '100K+' THEN 5
    END;