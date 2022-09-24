

drop table "plan"


select * from "plans" p;
select * from subscriptions s 



--How many customers has Foodie-Fi ever had?
select count (distinct customer_id) from subscriptions s  



--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select k.months, (value/count(value)*100) percentage from (select months, count(months) value from (select extract(month from start_date) months from (select start_date from subscriptions s 
where plan_id = 0) k) k
group by months   
order by months) k
group by k.value, k.months
order by months 



--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select p.plan_name, p.plan_id, count(*) from subscriptions s 
join "plans" p on p.plan_id=s.plan_id 
where start_date >= '2021-01-01'
group by p.plan_id, p.plan_name 
order by plan_id 



--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select (count(customer_id)::float/(select count (distinct customer_id) from subscriptions s2)::float*100), plan_name  from subscriptions s 
join "plans" p on p.plan_id=s.plan_id 
where plan_name = 'churn'
group by plan_name 

--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
select count(customer_id) numbers from (select * from (select customer_id, plan_id, start_date, lead(plan_id, 1 ) over(partition by customer_id order by start_date) sonra from subscriptions s 
order by customer_id, start_date) k
where plan_id=0 and sonra=4) k



--What is the number and percentage of customer plans after their initial free trial?
select plan_name, count(customer_id) from (select customer_id, p.plan_id, plan_name, row_number()over(partition by customer_id) sıralama from subscriptions s 
join "plans" p on p.plan_id=s.plan_id 
where p.plan_id=1 or p.plan_id=2 or p.plan_id=3 or p.plan_id=4) k
where sıralama = 1
group by plan_name
 



--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
select p.plan_id, (count(distinct customer_id)::float)/((select count(distinct customer_id)  from subscriptions s2)::float) *100 from subscriptions s 
join "plans" p on p.plan_id =s.plan_id 
where start_date <= '2020-12-31'
group by p.plan_id 


--How many customers have upgraded to an annual plan in 2020?
select plan_name, (pro_an::float)/(all_customer::float)*100 percentage from (select plan_name, count(customer_id) pro_an, (select count(distinct customer_id) from subscriptions s2) all_customer from (select customer_id, plan_name from subscriptions s 
join "plans" p on p.plan_id =s.plan_id 
where start_date < '2021-01-01' and start_date >= '2020-01-01') k
where plan_name = 'pro annual'
group by plan_name) k




--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
select avg("next"- start_date) from (select customer_id,plan_id,start_date, lead(start_date) over (partition by customer_id order by start_date) "next" from (select * from subscriptions s 
where plan_id=0 or plan_id =3
order by customer_id) k) k
where "next" is not null



--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
select aylar, (count(distinct customer_id)::float)/(tot_cus::float)*100 from (select customer_id, plan_id, (select count(distinct customer_id) from subscriptions s3) tot_cus, min_date, min_date/30+1 aylar from (select customer_id, plan_id, start_date -(select min(start_date) from subscriptions s2) min_date from subscriptions s) k) k 
group by aylar, tot_cus




--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
select count(customer_id) from (select *, lead(plan_id, 1) over (partition by customer_id order by start_date, plan_id), (select count(distinct customer_id) as num from subscriptions s2) from subscriptions s) k 
left join "plans" p on p.plan_id = k.plan_id
where plan_name='pro monthly' and k.plan_id=1 and start_date <= '2020-12-31'










