
create table co_fixed as select order_id,customer_id,pizza_id,order_time,
case 
	when exclusions like 'null' then null 
	when exclusions = '' then null 
	else exclusions end, 
case 
	when extras like 'null' then null 
	when extras = '' then null 
	else extras end from customer_orders co

select * from co_fixed cf;
create table ro_fixed as select * from (select * from (select order_id,
runner_id,
pickup_time,
left(distance, 2)::numeric as distance,
left(duration, 2)::numeric as duration,
case when cancellation = '' then null else cancellation end from (select order_id,
runner_id,
pickup_time,
regexp_replace(distance, '\D', '','g') as distance,
duration,
cancellation from (select order_id,runner_id,
case when pickup_time like 'null' then null else pickup_time end,
case when distance like 'null' then null else distance end,
case when duration like 'null' then null else duration end,
case when cancellation like 'null' then null else cancellation end from runner_orders ro) k) k) k) k







--How many pizzas were ordered?
select count(order_id) from co_fixed cf 




--How many unique customer orders were made?
select count(distinct order_id) from co_fixed cf 






--How many successful orders were delivered by each runner?
select count(runner_id) as sayi, runner_id from ro_fixed rf 
where cancellation is null
group by runner_id 






--How many of each type of pizza was delivered?
select count(pizza_id), pizza_id  from co_fixed cf 
group by pizza_id 





--How many Vegetarian and Meatlovers were ordered by each customer?
select count(customer_id) as cevap, customer_id, pizza_name from (select * from co_fixed cf
join pizza_names pn on pn.pizza_id=cf.pizza_id) k
group by customer_id, pizza_name 



--What was the maximum number of pizzas delivered in a single order?
select max(sayi) as max_order  from (select count(order_id) as sayi, order_id from co_fixed cf 
group by order_id ) k



--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, deisiklik, count(deisiklik) total from (select
	customer_id,
case 
	when exclusions is null and extras is null then 1 else 0
end deisiklik
from
	co_fixed cf) k
group by customer_id, deisiklik





--How many pizzas were delivered that had both exclusions and extras?
select count(order_id) as puan from (select order_id,customer_id,pizza_id,order_time,exclusions,extras from co_fixed cf 
where exclusions is not null and extras is not null) k





--What was the total volume of pizzas ordered for each hour of the day?
select count(order_id), hours from (select order_id, extract(hour from order_time) as hours from co_fixed cf) k
group by hours



--What was the volume of orders for each day of the week?
select case
	when deys = 0 then 'sunday'
	when deys = 1 then 'monday'
	when deys = 2 then 'tuesday'
	when deys = 3 then 'wednesday'
	when deys = 4 then 'thursday'
	when deys = 5 then 'friday'
	when deys = 6 then 'saturday'
end
deys, count(deys) as total from (select extract(dow from order_time) as deys from co_fixed cf) k
group by deys






















