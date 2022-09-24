


drop table "plan"


select * from "plans" p;
select * from subscriptions s 



--How many customers has Foodie-Fi ever had?
select count(*) customers from (select distinct (customer_id) from subscriptions s 
order by customer_id) k




--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select k.months, (value/count(value)*100) percentage from (select months, count(months) value from (select extract(month from start_date) months from (select start_date from subscriptions s 
where plan_id = 0) k) k
group by months   
order by months) k
group by k.value, k.months
order by months 




--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select (("next"::float)/(total_customer::float)*100)::int percentage, total_customer from (select sum(plan_id) "next", count(plan_id) total_customer from (
select customer_id, plan_id from subscriptions
where plan_id = 4) k) k







--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
select count(customer_id) from 
(
select * from (select * from 
(
select customer_id, plan_id, row_number()over(partition by customer_id) sıralama from subscriptions s 
) k
where sıralama = 1 or sıralama = 2
) k
where plan_id = 4
order by customer_id
) k



select customer_id, plan_id, row_number()over(partition by customer_id) sıralama from subscriptions s



--What is the number and percentage of customer plans after their initial free trial?



























/*select * from (select plan_id, count(plan_id) plan_numbers from (select customer_id, plan_id from
(
select customer_id, plan_id, row_number()over(partition by customer_id) sıralama from subscriptions s 
where plan_id > 0
) k
where sıralama = 1) k
group by plan_id) k *\


--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
select * from subscriptions s 



How many customers have upgraded to an annual plan in 2020?
How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
How many customers downgraded from a pro monthly to a basic monthly plan in 2020?