CREATE DATABASE task_data;
USE  task_data;

SELECT * FROM individual_incident_2020;

/*Executive Crime Summary Report--Aggregate Functions: COUNT(), SUM(), AVG()
Provides high-level executive summary for management dashboard.*/
SELECT 
    COUNT(*) AS total_incidents,
    SUM(total_offense) AS total_offenses,
    SUM(total_victim) AS total_victims,
    SUM(total_offender) AS total_offenders,
    SUM(property_value) AS total_property_loss,
    AVG(property_value) AS avg_property_loss
FROM individual_incident_2020;

/*State-wise Crime Performance Ranking -- GROUP BY,SUM(),Window Function: RANK()
--> Ranks states based on total crime volume.*/
SELECT state,
       SUM(total_offense) AS total_offense,
       RANK() OVER (ORDER BY SUM(total_offense) DESC) AS state_rank
FROM individual_incident_2020
GROUP BY state;

/*Top 5 States by Victim Count (CTE + Order + Limit) --WITH (CTE),GROUP BY,ORDER BY,LIMIT
--> Identifies high-risk states. */
WITH state_victims AS (
    SELECT state, SUM(total_victim) AS total_victims
    FROM individual_incident_2020
    GROUP BY state
)
SELECT *
FROM state_victims
ORDER BY total_victims DESC
LIMIT 5;

/*Incidents Above State Average Property Loss (Correlated Subquery) --> Correlated Subquery,AVG(),WHERE
--> Finds unusually high financial loss cases per state*/
SELECT incident_number, state, property_value
FROM individual_incident_2020 i1
WHERE property_value >
      (SELECT AVG(property_value)
       FROM individual_incident_2020 i2
       WHERE i1.state = i2.state);

/*Crime Category Classification (CASE Statement)
-- Classifies crime types for reporting and dashboard filtering.*/
SELECT incident_number,
CASE
    WHEN violence_offense > 0 THEN 'Violent Crime'
    WHEN theft_offense > 0 THEN 'Theft Crime'
    WHEN drug_offense > 0 THEN 'Drug Crime'
    ELSE 'Other Crime'
END AS crime_category
FROM individual_incident_2020;

/*Running Total of Victims (Trend Analysis)--  Windows Functions, SUM() OVER, Partition BY 
Shows victim growth trend over time.*/
SELECT state,
       date_HRF,
       SUM(total_victim) OVER (
           PARTITION BY state
           ORDER BY date_HRF
       ) AS running_victim_total
FROM individual_incident_2020;

/*Gender-Based Victim DistributionAggregate Functions 
--Useful for policy and gender safety analysis.*/
SELECT 
    SUM(male_victim) AS total_male_victims,
    SUM(female_victim) AS total_female_victims,
    SUM(unknown_sex_victim) AS unknown_gender
FROM individual_incident_2020;

/*High-Risk Night Crime Analysis--- WHERE,BETWEEN,GROUP BY,ORDER BY
Identifies crime-heavy night zones.*/
SELECT state, COUNT(*) AS night_cases
FROM individual_incident_2020
WHERE hour BETWEEN 20 AND 23
GROUP BY state
ORDER BY night_cases DESC;

/*Gun vs Non-Gun Crime Comparison --> CASE,Conditional Aggregation
Compares weapon involvement impact.*/
SELECT 
    SUM(CASE WHEN gun_involvement = 1 THEN 1 ELSE 0 END) AS gun_cases,
    SUM(CASE WHEN gun_involvement = 0 THEN 1 ELSE 0 END) AS non_gun_cases
FROM individual_incident_2020;

/*Data Quality Check (NULL Handling)--> IS NULL,COUNT()
Helps in data validation before reporting.*/
SELECT COUNT(*) AS missing_property_values
FROM individual_incident_2020
WHERE property_value IS NULL;


/*View for Client Dashboard -- CREATE VIEW,GROUP BY
Reusable structured data source for BI tools.*/
CREATE VIEW dashboard_summary AS
SELECT state,
       SUM(total_offense) AS total_offense,
       SUM(total_victim) AS total_victims,
       SUM(property_value) AS total_loss
FROM individual_incident_2020
GROUP BY state;

/*Top 5 States with Highest Property Loss-- SUM() (Aggregate Function),GROUP BY,ORDER BY,LIMIT
Calculates total property damage per state and shows top 5 highest loss states.*/
SELECT state,
       SUM(property_value) AS total_property_loss
FROM individual_incident_2020
GROUP BY state
ORDER BY total_property_loss DESC
LIMIT 5;

/*Incidents with Above-Average Victim Count --> Subquery,AVG() function,Comparison Operator >,
Finds incidents where victim count is higher than overall average.*/

SELECT *
FROM individual_incident_2020
WHERE total_victim > (
    SELECT AVG(total_victim)
    FROM individual_incident_2020
);

/*Rank States by Total Offenses (Window Function) -->SUM(),GROUP BY,RANK() Window Function,OVER() clause
Ranks states based on total number of offenses.*/
SELECT state,
       SUM(total_offense) AS total_offenses,
       RANK() OVER (ORDER BY SUM(total_offense) DESC) AS offense_rank
FROM individual_incident_2020
GROUP BY state;

/*Gun Involvement Percentage by State--> Aggregate functions,Arithmetic operator,GROUP BY*/
SELECT state,
       COUNT(*) AS total_incidents,
       SUM(gun_involvement) AS gun_cases,
       (SUM(gun_involvement) / COUNT(*)) * 100 AS gun_percentage
FROM individual_incident_2020
GROUP BY state;

/* Monthly Incident Trend --> Date Function MONTH(),GROUP BY,ORDER BY*/
SELECT MONTH(date_HRF) AS incident_month,
       COUNT(*) AS total_cases
FROM individual_incident_2020
GROUP BY MONTH(date_HRF)
ORDER BY incident_month;


/* Repeat ORI Agencies (More Than 100 Incidents)--> GROUP BY,HAVING,COUNT()*/
SELECT ORI,
       COUNT(*) AS incident_count
FROM individual_incident_2020
GROUP BY ORI
HAVING COUNT(*) > 100;

/* Running Total of Offenses (Window Function) -- Aggregate Function,Window Function,OVER(),ORDER BY*/
SELECT date_HRF,
       SUM(total_offense) AS daily_offense,
       SUM(SUM(total_offense)) OVER (ORDER BY date_HRF) AS running_total
FROM individual_incident_2020
GROUP BY date_HRF;



/*– High Risk Night Crimes (Between 8PM–5AM) -->  Uses:BETWEEN,Logical Operator OR*/
SELECT *
FROM individual_incident_2020
WHERE hour BETWEEN 20 AND 23
   OR hour BETWEEN 0 AND 5;


/* Theft vs Drug Offense Comparison -- SUM(),Aggregation comparison*/
SELECT 
    SUM(theft_offense) AS total_theft,
    SUM(drug_offense) AS total_drug
FROM individual_incident_2020;

-- calculates total offenses and victims per state
SELECT a.state,
       SUM(a.total_offense) AS total_offense,
       SUM(a.total_victim) AS total_victims
FROM individual_incident_2020 a
INNER JOIN individual_incident_2020 b
ON a.state = b.state
GROUP BY a.state;

-- Finds the incident with the highest property loss in each state.
SELECT state, incident_number, property_value
FROM individual_incident_2020 i
WHERE property_value = (
    SELECT MAX(property_value)
    FROM individual_incident_2020
    WHERE state = i.state
);

-- Running Difference in Offense
-- Calculates daily offense totals and compares them with the previous day.
SELECT date_HRF,
       SUM(total_offense) AS daily_total,
       SUM(total_offense) -
       LAG(SUM(total_offense)) OVER (ORDER BY date_HRF) AS difference
FROM individual_incident_2020
GROUP BY date_HRF;

-- Top 3 States
-- Ranks states based on total offenses and selects the top 3.
SELECT state, total_offense
FROM (
    SELECT state,
           SUM(total_offense) AS total_offense,
           ROW_NUMBER() OVER (ORDER BY SUM(total_offense) DESC) AS rn
    FROM individual_incident_2020
    GROUP BY state
) t
WHERE rn <= 3;

-- Theft vs Violence Ratio
-- Compares theft crimes with violent crimes per state.
-- Shows whether a state faces more property crime or violent crime.
SELECT state,
       SUM(theft_offense) AS total_theft,
       SUM(violence_offense) AS total_violence,
       (SUM(theft_offense) * 1.0 / SUM(violence_offense)) AS theft_violence_ratio
FROM individual_incident_2020
GROUP BY state;

-- offense Category Contribution Percentage
-- Calculates the percentage contribution of each offense type.
SELECT 
    SUM(violence_offense) * 100.0 / SUM(total_offense) AS violence_percent,
    SUM(theft_offense) * 100.0 / SUM(total_offense) AS theft_percent,
    SUM(drug_offense) * 100.0 / SUM(total_offense) AS drug_percent
FROM individual_incident_2020;
-- Filters records excluding specific states and selects evening crimes.
SELECT *
FROM individual_incident_2020
WHERE state NOT IN ('CA', 'TX')
AND hour BETWEEN 18 AND 23;


