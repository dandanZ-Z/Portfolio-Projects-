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
**1. How many customers has Foodie-Fi ever had?**

```sql

```
Ouput:
<markdown table output here>
  
***

**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.**

````sql

````
Output:


***

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.**

````sql

````
Output:


***

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

````sql

````
Ouput:

***

**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

```sql
```

utput:


***

**6. What is the number and percentage of customer plans after their initial free trial?**

```sql

```
Output:

***

**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

````sql

````
Ouput:

***

**8. How many customers have upgraded to an annual plan in 2020?**

```sql

```
Output:

***

**9. How many days on average does it take for a customer to convert to an annual plan from the day they join Foodie-Fi?**

```sql

```
Ouput:

***

**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

```sql
```
Ouput:

***

**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```sql
```
Ouput:


