-- Absenteeism Analytics --

-- Create the database
CREATE DATABASE IF NOT EXISTS absence_tracker;
USE absence_tracker;

-- Import three tables from the dataset: absenteeism_at_work, reasons and compensation

-- Retrieve Absenteeism Data
SELECT * FROM absence_tracker.absenteeism_at_work;
SELECT * FROM absence_tracker.reasons;
SELECT * FROM absence_tracker.compensation;
-- Wrangling Data -- 

-- Check Data Types and Constraints for the three tables
DESCRIBE absenteeism_at_work;
DESCRIBE reasons;
DESCRIBE compensation;

-- Identify Missing Data in absenteeism_at_work table: Retrieves rows where ID column has a NULL value
SELECT * FROM absence_tracker.absenteeism_at_work
WHERE ID IS NULL;

-- Check for Duplicates in absenteeism_at_work table
SELECT
	ID,
    COUNT(*) AS total_rows
FROM
	absence_tracker.absenteeism_at_work
GROUP BY ID
HAVING total_rows > 1;
    
-- Exploring Data --

-- Review Categorical Columns
SELECT DISTINCT Reason
FROM reasons
ORDER BY Reason;

-- Understanding the Distribution of `Absenteeism time in hours` Column
SELECT
    MIN(`Absenteeism time in hours`) AS min_absence_hours,
    MAX(`Absenteeism time in hours`) AS max_absence_hours,
    AVG(`Absenteeism time in hours`) AS average_absence_hours,
    COUNT(*) AS total_rows
FROM absenteeism_at_work;

-- The range of compensation per hour in the dataset
SELECT
	MIN(`comp/hr`) AS min_compensation_per_hour,
    MAX(`comp/hr`) AS max_compensation_per_hour
FROM
	compensation;

-- Compensation per hour and how it varys across different employee or reasons for absence
SELECT
	a.ID AS employee_ID,
    r.`Reason` AS absence_reason,
    c.`comp/hr` AS hourly_compensation
FROM absenteeism_at_work AS a
JOIN compensation AS c
ON a.ID = c.ID
JOIN reasons AS r
ON a.`Reason for absence` = r.`Number`;

-- Unique reason number in the dataset
SELECT COUNT(DISTINCT Reason) AS unique_reason_number
FROM reasons;

-- The certain reasons which are more common than others
SELECT
	a.`Reason for absence` AS absence_reason,
    r.Reason,
    COUNT(*) AS reasons_count
FROM absenteeism_at_work AS a
JOIN reasons AS r
ON a.`Reason for absence` = r.`Number`
GROUP BY a.`Reason for absence`,  r.Reason
ORDER BY reasons_count DESC;

-- Reasons for absence which are more prevalent during specific seasons 
SELECT
	r.`Reason`,
    (CASE a.`Seasons`
        WHEN 1 THEN 'Spring'
        WHEN 2 THEN 'Summer'
        WHEN 3 THEN 'Fall'
        WHEN 4 THEN 'Winter'
        ELSE 'Unknown'  -- Handle any unexpected values
    END) AS season_name,
    COUNT(*) AS reason_count
FROM absence_tracker.absenteeism_at_work AS a
JOIN absence_tracker.reasons AS r
ON a.`Reason for absence` = r.`Number`
GROUP BY a.Seasons, r.`Reason`
ORDER BY reason_count DESC;

--  The count of absenteeism occurrences for each season
SELECT
	   (CASE
        WHEN `Month of absence` IN (12,1,2) THEN 'Winter'
        WHEN `Month of absence` IN (3,4,5) THEN 'Spring'
        WHEN `Month of absence` IN (6,7,8) THEN 'Summer'
        WHEN `Month of absence` IN (9,10,11) THEN 'Fall'
        ELSE 'Unknown'  -- Handle any unexpected values
    END) AS Season_Name,
    COUNT(*) AS Reason_count
FROM absence_tracker.absenteeism_at_work
GROUP BY Season_Name
ORDER BY Reason_count DESC;

-- Absenteeism and how it varys across different months
SELECT
   ( CASE `Month of absence`
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
	ELSE 'Unknown' 
	END ) AS Month_name,
    COUNT(*) AS absence_count
FROM absenteeism_at_work
GROUP BY `Month of absence`
ORDER BY absence_count DESC;

-- Days of the week which have the highest and lowest rates of absenteeism
SELECT
	( CASE `Day of the week`
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
	ELSE 'Unknown'
    END ) AS day_name,
    count(*) AS absenteeism_count
FROM absenteeism_at_work
GROUP BY day_name
ORDER BY absenteeism_count DESC;

-- A breakdown of absenteeism by both the day of the week and the reason for absence
SELECT 
	( CASE a.`Day of the week`
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
	ELSE 'Unknown'
    END ) AS Day_name,
	r.`Reason`,
    COUNT(*) AS Reason_count
FROM absence_tracker.absenteeism_at_work AS a
JOIN absence_tracker.reasons AS r
ON a.`Reason for absence` = r.`Number`
GROUP BY Day_name, r.`Reason`
ORDER BY Reason_count DESC;

-- Create a join table
SELECT * FROM absence_tracker.absenteeism_at_work AS a
LEFT JOIN compensation AS c
ON a.ID = c.ID
LEFT JOIN reasons AS r
ON a.`Reason for absence` = r.`Number`;

-- Retrieve Employee ID and Absence Reason
SELECT 
	a.ID,
    r.Reason
FROM absence_tracker.absenteeism_at_work AS a
LEFT JOIN reasons AS r
ON a.`Reason for absence` = r.`Number`;

-- Using Views for Workday Absenteeism Analysis
CREATE VIEW WorkdayAbsenteeism AS
SELECT
    `Day of the week`,
    COUNT(*) AS absence_count
FROM
    absenteeism_at_work
WHERE
    `Day of the week` BETWEEN 2 AND 5
GROUP BY
    `Day of the week`;

SELECT *
FROM
    WorkdayAbsenteeism
ORDER BY
    `Day of the week`;

-- Using CTEs for Monthly Absenteeism Analysis
WITH MonthlyAbsenteeism AS (
    SELECT
       `Month of absence`,
        COUNT(*) AS absence_count
    FROM
        absenteeism_at_work
    GROUP BY
        `Month of absence`
)
SELECT
    (CASE ma.`Month of absence`
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Unknown'
    END) AS Month_name,
    ma.absence_count,
    r.`Reason`
FROM
    MonthlyAbsenteeism ma
JOIN
    reasons r ON ma.`Month of absence` = r.`Number`
WHERE ma.`Month of absence` BETWEEN 1 AND 12
ORDER BY
    ma.`Month of absence`, ma.absence_count DESC;
    
-- Absenteeism Patterns for Social Smokers vs. Non-Smokers
SELECT
    CASE `Social smoker`
        WHEN 0 THEN 'Non_Smoker'
        WHEN 1 THEN 'Smoker'
        ELSE 'Unknown'
    END AS Smoking_status,
    COUNT(*) AS Absence_count
FROM
    absenteeism_at_work
GROUP BY
    `Social smoker`
ORDER BY
    `Social smoker`;
    
-- Absenteeism Patterns for Social Drinker vs. Non-Drinker
SELECT
    CASE `Social drinker`
        WHEN 0 THEN 'Non_Drinker'
        WHEN 1 THEN 'Drinker'
        ELSE 'Unknown'
    END AS Drinking_status,
    COUNT(*) AS Absence_count
FROM
    absenteeism_at_work
GROUP BY
    `Social drinker`
ORDER BY
    `Social drinker`;
    
-- Absenteeism Patterns for Disciplinary Failure
SELECT
	CASE
		WHEN `Disciplinary failure` = 0 THEN 'No_Disciplinary_Failure'
        WHEN `Disciplinary failure` = 1 THEN 'Disciplinary_Failure'
		ELSE 'Unknown'
	END AS 'Disciplinary_status',
    COUNT(*) AS Absence_count
FROM
	absenteeism_at_work
GROUP BY `Disciplinary failure`
ORDER BY `Disciplinary failure`;

-- Employee Demographics: Analyze the Distribution of Ages
SELECT
	age,
    COUNT(*) AS Absence_count
FROM
	absenteeism_at_work
GROUP BY age
ORDER BY age;

SELECT
	ROUND(AVG(age),2) AS AVG_age
FROM
	absenteeism_at_work;
    
--  The range of Ages in the Dataset
SELECT
    MIN(age) AS Min_age,
    MAX(age) AS Max_age
FROM
    absenteeism_at_work;

-- Analyze the Impact of Distance on Absenteeism
SELECT
    `Distance from Residence to Work`,
    ROUND(AVG(`Absenteeism time in hours`),2) AS AVG_absenteeism_time
FROM
    absenteeism_at_work
GROUP BY
    `Distance from Residence to Work`
ORDER BY
    `Distance from Residence to Work`;
    
/* 

 Visualization Query for Employee Absenteeism 
 
 */

SELECT
    a.ID,
    r.Reason,
     (CASE a.`Month of absence`
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END) AS Month_name,
    a.`Body mass index`,
    CASE
        WHEN `Body mass index` < 18.5 THEN 'Underweight'
        WHEN `Body mass index` >= 18.5 AND `Body mass index` < 25 THEN 'Normal Weight'
        WHEN `Body mass index` >= 25 AND `Body mass index` < 30 THEN 'Overweight'
        WHEN `Body mass index` >= 30 THEN 'Obese'
        ELSE 'Unknown'
    END AS BMI_Category,
    (CASE
        WHEN a.`Month of absence` IN (12,1,2) THEN 'Winter'
        WHEN a.`Month of absence` IN (3,4,5) THEN 'Spring'
        WHEN a.`Month of absence` IN (6,7,8) THEN 'Summer'
        WHEN a.`Month of absence` IN (9,10,11) THEN 'Fall'
        ELSE 'Unknown'  -- Handle any unexpected values
    END) AS Season_Name,
    a.Seasons,
    a.`Month of absence`,
    a.`Day of the week`,
    a.`Transportation expense`,
    a.`Education`,
    a.`Son`,
     CASE a.`Social drinker`
        WHEN 0 THEN 'Non_Drinker'
        WHEN 1 THEN 'Drinker'
        ELSE 'Unknown'
    END AS Drinking_status,
    CASE a.`Social smoker`
        WHEN 0 THEN 'Non_Smoker'
        WHEN 1 THEN 'Smoker'
        ELSE 'Unknown'
    END AS Smoking_status,
    a.`Pet`,
    CASE
		WHEN `Disciplinary failure` = 0 THEN 'No_Disciplinary_Failure'
        WHEN `Disciplinary failure` = 1 THEN 'Disciplinary_Failure'
		ELSE 'Unknown'
	END AS 'Disciplinary_status',
	a.Age,
	a.`Work load Average/day`, 
	a.`Absenteeism time in hours`
FROM
    absence_tracker.absenteeism_at_work AS a
JOIN Reasons AS r
ON a.`Reason for absence` = r.`Number`
LEFT JOIN compensation AS c
ON a.ID = c.ID;

/* 

 Conclusion:

Based on the analysis, key findings include:
- Absenteeism patterns vary across months, with higher occurrences in certain seasons.
- Certain reasons for absence are more common than others.
- Absence rates are influenced by the day of the week.
- Social and disciplinary factors impact absenteeism.

These insights can inform HR strategies for managing absenteeism and improving employee well-being.

*/