## A: Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table,
write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

```sql
SELECT CUSTOMER_ID, PL_PLAN_ID, START_DATE
FROM JOINED
ORDER BY CUSTOMER_ID, PL_PLAN_ID
```
Output: (limited to 10/2650 rows)
| customer_id | pl_plan_id | start_date |
|-------------|------------|------------|
| 1           | 0          | 2020-08-01 |
| 1           | 1          | 2020-08-08 |
| 2           | 0          | 2020-09-20 |
| 2           | 3          | 2020-09-27 |
| 3           | 0          | 2020-01-13 |
| 3           | 1          | 2020-01-20 |
| 4           | 0          | 2020-01-17 |
| 4           | 1          | 2020-01-24 |
| 4           | 4          | 2020-04-21 |
| 5           | 0          | 2020-08-03 |


We see that customers all start with plan 0(trial), after a week they switch to a permanent plan.

## B: Data Analysis 

Connect the data into a join for ease of access:
```sql
CREATE OR REPLACE VIEW JOINED AS
SELECT SUB.CUSTOMER_ID,
	SUB.PLAN_ID AS SUB_PLAN_ID,
	SUB.START_DATE,
	PL.PLAN_ID AS PL_PLAN_ID,
	PL.PLAN_NAME,
	PL.PRICE
FROM FF3.SUBSCRIPTIONS SUB
INNER JOIN FF3.PLANS PL ON SUB.PLAN_ID = PL.PLAN_ID;
```


**1. How many customers has Foodie-Fi ever had?**

```sql
SELECT COUNT (DISTINCT CUSTOMER_ID)
FROM JOINED
```
Ouput:
| count |
|-------|
| 1000  |

  
***

**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.**

````sql
SELECT TO_CHAR(DATE_TRUNC('month', start_date), 'Month') AS month,
       COUNT(*) AS month_distribution
FROM joined
WHERE pl_plan_id = 0
GROUP BY month, DATE_TRUNC('month', start_date)
ORDER BY DATE_TRUNC('month', start_date)
````
Output:
|    month    | month_distribution |
|-------------|-------------------|
| January     | 88                |
| February    | 68                |
| March       | 94                |
| April       | 81                |
| May         | 88                |
| June        | 79                |
| July        | 89                |
| August      | 88                |
| September   | 87                |
| October     | 79                |
| November    | 75                |
| December    | 84                |


***

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.**

````sql
select pl_plan_id,count(pl_plan_id) as nu_plans from joined 
where start_date >= '2021-01-01 00:00:00+08'
group by pl_plan_id
order by pl_plan_id
````
Output:
| pl_plan_id | nu_plans |
|------------|----------|
| 1          | 8        |
| 2          | 60       |
| 3          | 63       |
| 4          | 71       |


***

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

````sql
SELECT ROUND(COUNT(DISTINCT CASE
				   WHEN PLAN_NAME = 'churn' THEN CUSTOMER_ID
				   END) * 100.0 / COUNT(DISTINCT CUSTOMER_ID),
      				1) AS CHURN_PERCENT, COUNT(DISTINCT CASE
				   WHEN PLAN_NAME = 'churn' THEN CUSTOMER_ID
				   END) as nu_churn
FROM JOINED
````
Ouput:
| churn_percent | nu_churn |
|--------------|----------|
| 30.7         | 307      |

***

**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

```sql
SELECT 
  ROUND(COUNT(DISTINCT CASE 
                      WHEN sub.pl_plan_id = 4 THEN sub.customer_id  
                    END)  / (SELECT COUNT(DISTINCT customer_id) 
                            FROM joined) * 100.0) AS churn_percentage, 
  COUNT(DISTINCT sub.customer_id) AS num_customers
FROM (
  SELECT 
    customer_id, 
    pl_plan_id, 
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY start_date) AS plan_rank
  FROM joined
) sub 
JOIN joined ON sub.customer_id = joined.customer_id
WHERE sub.pl_plan_id = 4 AND sub.plan_rank = 2
```

Output:
| churn_percentage | num_customers |
|------------------|---------------|
| 0                | 92            |


***

**6. What is the number and percentage of customer plans after their initial free trial?**

```sql
WITH ranking AS (
  SELECT 
    customer_id, 
    pl_plan_id, 
    plan_name,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY start_date
    ) AS plan_rank
  FROM joined
)
SELECT 
  ranking.plan_name, 
  COUNT(ranking.plan_name) AS nu_in_plan,
  ROUND(COUNT(ranking.plan_name) / 
        (SELECT COUNT(DISTINCT customer_id) 
         FROM joined 
         WHERE pl_plan_id = 0) * 100.00, 2) AS percent
FROM 
  ranking
  JOIN joined ON ranking.customer_id = joined.customer_id
WHERE 
  ranking.plan_rank = 2
GROUP BY 
  ranking.plan_name,
  ranking.pl_plan_id
ORDER BY 
  ranking.pl_plan_id
```
Output:
| plan_name      | nu_in_plan | percent |
|----------------|------------|---------|
| basic monthly  | 1592       | 100.00  |
| pro monthly    | 798        | 0.00    |
| pro annual     | 76         | 0.00    |
| churn          | 184        | 0.00    |

***

**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

````sql
SELECT 
  COUNT(DISTINCT customer_id) AS nu_in_plan, 
  plan_name, 
  MAX(pl_plan_id) AS current_plan_id,
  (COUNT(DISTINCT customer_id) / CAST((SELECT COUNT(DISTINCT customer_id) FROM joined) AS numeric) * 100.00) AS percent_of_total
FROM 
  joined
WHERE 
  start_date < '2020-12-31'
GROUP BY 
  plan_name
HAVING 
  MAX(pl_plan_id) != 0
````
Output:
| nu_in_plan | plan_name      | current_plan_id | percent_of_total |
|------------|----------------|-----------------|------------------|
| 538        | basic monthly  | 1               | 53.80            |
| 235        | churn          | 4               | 23.50            |
| 195        | pro annual     | 3               | 19.50            |
| 479        | pro monthly    | 2               | 47.90            |

***

**8. How many customers have upgraded to an annual plan in 2020?**

```sql
SELECT COUNT(DISTINCT CUSTOMER_ID)
FROM JOINED
WHERE PL_PLAN_ID = '3'
	AND START_DATE BETWEEN '2020-01-01' AND '2020-12-31'
```
Output:
| count |
|-------|
| 195   |

***

**9. How many days on average does it take for a customer to convert to an annual plan from the day they join Foodie-Fi?**

```sql
WITH ranking AS (
  SELECT 
    customer_id, 
    pl_plan_id, 
    plan_name, 
    start_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY start_date
    ) AS row_number
  FROM 
    joined),
	
annual AS (	 
  SELECT * FROM ranking
  WHERE row_number = 2 AND pl_plan_id = 3),
  
trial AS (	  
  SELECT * FROM ranking 
  WHERE row_number = 1 AND pl_plan_id = 0)
  
SELECT 
  AVG(EXTRACT(DAY FROM (annual.start_date - trial.start_date))) AS avg_days_diff
FROM annual
INNER JOIN trial
    ON annual.customer_id = trial.customer_id;

	  
SELECT 
  AVG(EXTRACT(DAY FROM (annual.start_date - trial.start_date))) AS avg_days_diff
FROM 
  (SELECT customer_id, start_date FROM joined WHERE pl_plan_id = 0) AS trial
  INNER JOIN 
  (SELECT customer_id, start_date FROM joined WHERE pl_plan_id = 3) AS annual
  ON trial.customer_id = annual.customer_id
```
Ouput:

***

**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

```sql
WITH ranking AS (
  SELECT 
    customer_id, 
    pl_plan_id, 
    plan_name, 
    start_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY start_date
    ) AS row_number
  FROM 
    joined
),
annual AS (	 
  SELECT * FROM ranking
  WHERE row_number = 2 AND pl_plan_id = 3
),
trial AS (	  
  SELECT * FROM ranking 
  WHERE row_number = 1 AND pl_plan_id = 0
)
SELECT 
  CASE 
    WHEN days_diff BETWEEN 0 AND 30 THEN '0-30 days'
    WHEN days_diff BETWEEN 31 AND 60 THEN '31-60 days'
    WHEN days_diff BETWEEN 61 AND 90 THEN '61-90 days'
    ELSE '90+ days'
  END AS period,
  COUNT(*) AS num_customers,
  AVG(days_diff) AS avg_days_diff
FROM (
  SELECT 
    annual.customer_id, 
    EXTRACT(DAY FROM (annual.start_date - trial.start_date)) AS days_diff
  FROM 
    annual 
    INNER JOIN trial ON annual.customer_id = trial.customer_id
) AS diffs
GROUP BY period
```
Output:

***

**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```sql
with ranking as (
SELECT 
    customer_id, 
    pl_plan_id, 
    plan_name, 
    start_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY start_date
    ) AS row_number
  FROM 
    joined
where START_DATE BETWEEN '2020-01-01' AND '2020-12-31'),
BasicMonth AS (	 
  SELECT * FROM ranking
  WHERE pl_plan_id = 1
),
ProMonth AS (	  
  SELECT * FROM ranking 
  WHERE  pl_plan_id = 2),
clean AS (
  SELECT 
    BasicMonth.customer_id 
  FROM 
    BasicMonth 
    JOIN ProMonth ON BasicMonth.customer_id = ProMonth.customer_id
  WHERE 
    BasicMonth.start_date > ProMonth.start_date
)

SELECT 
  customer_id 
FROM 
  clean
```
Ouput:
0. Meaning no customers downgraded 


