USE hospital_operations;

-- Q1: Retrieve patients older than 60, sorted from oldest to youngest
select patient_id, age
from patients
where age > 60
order by age DESC;

-- Q2: Count patients with BMI greater than 30
select count(*) AS patient_count
from patients
where bmi > 30;

-- Q3: Count number of patients grouped by sex
select sex, count(*) AS patient_count
from patients 
group by sex;

-- Q4: Find average BMI per sex, rounded to 2 decimals, sorted highest to lowest
select sex, ROUND(AVG(bmi), 2) AS Avg_bmi
from patients
group by sex 
order by Avg_bmi DESC;

-- Q5: List the distinct smoking status categories in the patients table
select DISTINCT smoking_status
from patients;

-- Q6: Top 5 oldest obese patients (BMI > 30)
select patient_id, age, bmi
from patients
where bmi > 30
order by age DESC LIMIT 5;

-- Q7: Join patients with outcome table to show admitted patients' age and charges
select p.patient_id, p.age, o.total_charges_usd
from patients p Inner join outcome o 
ON p.patient_id = o.patient_id;

-- Q8: Discharge dispositions with more than 1000 admissions
select discharge_disposition, count(admission_date) AS admissions 
from outcome
group by discharge_disposition
having count(admission_date) > 1000;

-- Q9: Average total charges by sex (join patients + outcome)

select p.sex, Avg(o.total_charges_usd) AS Total_charges
from patients p Inner Join outcome o 
on p.patient_id = o.patient_id 
group by sex;

-- Q10: Categorize patients into age groups using CASE, count each group 'Under 40', '40 to 64', and '65 and above'
select 
CASE
WHEN age < 40 THEN 'UNDER 40'
WHEN age BETWEEN 40 AND 64 THEN '40 to 64'
ELSE '65 And Above'
END AS age_group,
Count(*) AS patient_count
from patients 
group by age_group;

-- Q11: Patients with BMI above the overall average BMI
Select patient_id, bmi
from patients 
WHERE bmi > (select AVG(bmi) AS Avg_bmi
from patients);

-- Q12: Patients diagnosed with hypertension (join patients + diagnoses)
select p.patient_id, p.age
from patients p Inner Join diagnoses d 
ON p.patient_id = d.patient_id 
where d.primary_diagnosis = 'hypertension';

-- Q13: Patients who have NOT been diagnosed with hypertension
select patient_id, age
from patients
where patient_id NOT IN (
    select patient_id
    from diagnoses
    where primary_diagnosis = 'hypertension'
);

-- Q14: Patients who were never admitted (no matching row in outcome)

select p.patient_id, p.age
from patients p left join outcome o
ON p.patient_id =o.patient_id 
where o.patient_Id IS NULL;

-- Q15: Rank patients by total_charges_usd, highest to lowest
select patient_id, 
       total_charges_usd, 
       RANK() OVER (ORDER BY total_charges_usd DESC) AS charge_rank
from outcome;

-- Q16: Rank patients by total_charges_usd within each discharge_disposition group
select patient_id, discharge_disposition, total_charges_usd,
RANK() OVER( PARTITION BY discharge_disposition Order by total_charges_usd DESC) AS Charge_Rank
from outcome;


-- Q17: Top 3 highest-charge patients within each discharge_disposition group
WITH ranked_outcomes AS (
    select patient_id, discharge_disposition, total_charges_usd,
           RANK() OVER (
               PARTITION BY discharge_disposition
               ORDER BY total_charges_usd DESC
           ) AS charge_rank
    from outcome
)
select *
from ranked_outcomes
where charge_rank <= 3;


-- Q18: Patients with BMI above the average BMI for their own sex (correlated subquery)
select p1.patient_id, p1.sex, p1.bmi
from patients p1
where p1.bmi > (
    select avg(p2.bmi)
    from patients p2
    where p2.sex = p1.sex
);

-- Q19: Patients diagnosed with hypertension, using EXISTS
select patient_id, age
from patients p
where exists (
    select 1
    from diagnoses d
    where d.patient_id = p.patient_id
    and d.primary_diagnosis = 'hypertension'
);
