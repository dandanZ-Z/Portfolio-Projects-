--A. Pizza Metrics
CREATE OR REPLACE VIEW JOINED AS
SELECT CO.ORDER_ID,
	CO.CUSTOMER_ID,
	PN.PIZZA_NAME,
	PR.TOPPINGS,
	CASE
					WHEN CO.EXCLUSIONS = ''
					OR CO.EXCLUSIONS = 'null' THEN NULL
					ELSE CAST(REGEXP_REPLACE(CO.EXCLUSIONS, '[ ,]+', '', 'g') AS INTEGER)
	END AS EXCLUSIONS_CLEANED,
	CASE
					WHEN CO.EXTRAS = ''
					OR CO.EXTRAS = 'null' THEN NULL
					ELSE CAST(REGEXP_REPLACE(CO.EXTRAS, '[ ,]+', '', 'g') AS INTEGER)
	END AS EXTRAS_CLEANED,
	CO.ORDER_TIME,
	RO.RUNNER_ID,
	R.REGISTRATION_DATE,
	CAST(NULLIF(RO.PICKUP_TIME, 'null') AS TIMESTAMP WITHOUT TIME ZONE) AS PICKUP_TIME,
	CASE
			WHEN RO.DISTANCE = '' OR RO.DISTANCE = 'null' THEN NULL
			ELSE CAST(REGEXP_REPLACE(RO.DISTANCE, '[^0-9\.]', '', 'g') AS DECIMAL(7, 2))
	END AS DISTANCE_KM,
	CASE
			WHEN RO.DURATION = '' OR RO.DURATION = 'null' THEN NULL
			ELSE CAST(REGEXP_REPLACE(RO.DURATION, '[^0-9]', '', 'g') AS INTEGER)
	END AS DURATION_MINS,
	CASE
			WHEN RO.CANCELLATION = '' OR RO.CANCELLATION = 'null' THEN NULL
			ELSE RO.CANCELLATION
	END AS CANCELS
FROM PR2.CUSTOMER_ORDERS CO
JOIN PR2.PIZZA_NAMES PN ON CO.PIZZA_ID = PN.PIZZA_ID
JOIN PR2.PIZZA_RECIPES PR ON CO.PIZZA_ID = PR.PIZZA_ID
JOIN PR2.RUNNER_ORDERS RO ON CO.ORDER_ID = RO.ORDER_ID
JOIN PR2.RUNNERS R ON RO.RUNNER_ID = R.RUNNER_ID;



--1. How many pizzas were ordered?
select count(order_id) as pizzas_ordered
from joined;


--2. How many unique customer orders were made?
select count(distinct order_id) as no_of_orders
from joined


--3. How many successful orders were delivered by each runner?
select count (distinct pickup_time) as successful_orders from joined
where pickup_time != 'null';


--4. How many of each type of pizza was delivered?
select pizza_name, count (pizza_name) as number_delivered from joined
group by pizza_name;


--5. How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, pizza_name, count (pizza_name) as number_delivered from joined
group by customer_id, pizza_name
order by customer_id;


--6. What was the maximum number of pizzas delivered in a single order?
select customer_id, pizza_name, count (pizza_name) as number_delivered from joined
group by customer_id, pizza_name
order by number_delivered desc
limit 1;


--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT CUSTOMER_ID,
	COUNT(CASE
											WHEN EXCLUSIONS_CLEANED IS NOT NULL
																OR EXTRAS_CLEANED IS NOT NULL THEN 1
							END) AS CHANGED_PIZZAS,
	COUNT(CASE
											WHEN EXCLUSIONS_CLEANED IS NULL
																AND EXTRAS_CLEANED IS NULL THEN 1
							END) AS NO_CHANGE
FROM JOINED
WHERE DISTANCE IS NOT NULL
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS NU_PIZZAS
FROM JOINED
WHERE EXCLUSIONS_CLEANED IS NOT NULL
	AND EXTRAS_CLEANED IS NOT NULL


--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATE_TRUNC('hour',ORDER_TIME),
	COUNT(*)AS NU_PIZZAS
FROM JOINED
GROUP BY ORDER_TIME
ORDER BY ORDER_TIME


--10. What was the volume of orders for each day of the week?
SELECT to_char(order_time, 'DAY') AS day, COUNT(*) AS nu_orders
FROM joined
GROUP BY to_char(order_time, 'DAY')



-- B. Runner and Customer Experience
--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATE_TRUNC('week',

								REGISTRATION_DATE) AS REGISTRATION_WEEK,
	COUNT(DISTINCT RUNNER_ID) AS COUNT
FROM JOINED
WHERE REGISTRATION_DATE > '2021-01-01 00:00:00+08'
GROUP BY REGISTRATION_WEEK


--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT RUNNER_ID,
	AVG(DURATIONS_MINS) AS TIME
FROM JOINED
WHERE DURATIONS_MINS IS NOT NULL
GROUP BY RUNNER_ID
ORDER BY RUNNER_ID


--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT ORDER_ID,
	COUNT(ORDER_ID) AS NU_PIZZAS,
	AVG(PICKUP_TIME - ORDER_TIME) AS TIME_TAKEN
FROM JOINED
GROUP BY ORDER_ID
ORDER BY NU_PIZZAS
--There is a relationship, we can see a trend of more pizzas = more time taken


--4. What was the average distance travelled for each customer?
SELECT CUSTOMER_ID,
	AVG(DISTANCE_KM) AS AVG_DIST
FROM JOINED
WHERE DISTANCE_KM IS NOT NULL
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID


--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(DURATION_MINS) - MIN(DURATION_MINS) AS DIFFERENCE
FROM JOINED
WHERE DURATION_MINS IS NOT NULL


--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT DISTINCT RUNNER_ID,
	AVG(DISTANCE_KM / DURATION_MINS) AS SPEED
FROM JOINED
WHERE CANCELS IS NULL
GROUP BY RUNNER_ID
ORDER BY SPEED DESC


--7. What is the successful delivery percentage for each runner?
SELECT RUNNER_ID,
	COUNT(CASE
						WHEN CANCELS IS NULL THEN 1
						END) / COUNT(DISTINCT ORDER_ID) * 100 AS SUCCESS_PERCENT
FROM JOINED
GROUP BY RUNNER_ID
