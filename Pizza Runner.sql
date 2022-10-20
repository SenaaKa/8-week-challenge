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





--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select weeks, count(weeks) from (select extract(week from registration_date+3) as weeks from runners r) k
group by weeks



--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select avg(pickup_time::timestamp - order_time) from (select * from co_fixed cf
left join ro_fixed rf  on cf.order_id=rf.order_id) k






--Is there any relationship between the number of pizzas and how long the order takes to prepare?
select *, difference/volume as average from (select count(order_id) as volume, (pickup_time::timestamp-order_time) as difference from (select cf.order_id, order_time, pickup_time from co_fixed cf
left join ro_fixed rf on rf.order_id=cf.order_id) k
group by difference) k
--There is no realtionship between the number of pizzas and how long the order takes to prepare.





--What was the average distance travelled for each customer?
select customer_id, avg(distance) average from co_fixed cf 
left join ro_fixed rf on rf.order_id=cf.order_id 
group by customer_id




--What was the difference between the longest and shortest delivery times for all orders?
select min(duration), max(duration)  from ro_fixed rf 




--What was the average speed for each runner for each delivery and do you notice any trend for these values?
select order_id, distance/duration*60 from ro_fixed rf 



--What is the successful delivery percentage for each runner?
select runner_id,(sum(distance)::float/count(distance)::float*100) as percentage from (select runner_id, 
case 
	when distance is not null then 1
	when distance is null then 0
end
distance from ro_fixed rf) k
group by runner_id 




select * from (select runner_id, 
case 
	when distance is not null then 1
	when distance is null then 0
end
distance from ro_fixed rf) k










--What are the standard ingredients for each pizza?
select pizza_name, array_to_string(array_agg(topping_name), ',') from (select * from (select pizza_id, unnest(string_to_array(toppings, ', '))::int as toppings from pizza_recipes pr) k
left join pizza_toppings pt on pt.topping_id=k.toppings
left join pizza_names pn on pn.pizza_id=k.pizza_id) k
group by pizza_name




--What was the most commonly added extra?   --1.çözüm
select topping_name, volume from (select topping_name, count(topping_name) as volume from (select pizza_id,unnest(string_to_array(extras, ', '))::int as extras from co_fixed cf) k
left join pizza_toppings pt on k.extras=pt.topping_id 
group by topping_name) k
where volume = (select max(volume) from (select topping_name, count(topping_name) as volume from (select pizza_id,unnest(string_to_array(extras, ', '))::int as extras from co_fixed cf) k
left join pizza_toppings pt on k.extras=pt.topping_id 
group by topping_name) k)


--2.çözüm
select topping_name, volume from (select topping_name, volume, dense_rank()over(order by volume desc) as dr from (select topping_name, count(topping_name) as volume from (select pizza_id,unnest(string_to_array(extras, ', '))::int as extras from co_fixed cf) k
left join pizza_toppings pt on k.extras=pt.topping_id 
group by topping_name) k) k
where dr = 1 






--What was the most common exclusion?
select * from (select topping_name, volume, dense_rank()over(order by volume desc) as dr from (select pt.topping_name, count(pt.topping_name) as volume from (select pizza_id, unnest(string_to_array(exclusions, ','))::int as exclusions from co_fixed cf) k
left join pizza_toppings pt on k.exclusions=pt.topping_id 
group by pt.topping_name) k) k
where dr = 1







/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
select order_id,
exclusions,
extras,
pizza_name, 
case 
	when pizza_name like 'Meatlovers' then 'Meat lovers'
	when pizza_name like 'Meatlovers' and exclusions like '%3%' then 'Meat Lovers - Exclude Beef'
	else pizza_name 
end
from co_fixed cf 
join pizza_names pn on pn.pizza_id=cf.pizza_id




/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers 
SOL 2  */ 

select order_id, concat(pizza_name,'- Exclude ' ,exclusions, '- Extras ', extras) from (
select
	order_id,
	pizza_name,
	array_to_string(array_agg(exclusions),',  ') exclusions ,
	array_to_string(array_agg(extras),',  ') extras
from (select
	distinct
	order_id ,
	pizza_id,
	pt.topping_name exclusions,
	pt2.topping_name extras
from
	(
	select
		cf.order_id ,
		cf.pizza_id ,
		k.exclusions::int ,
		k.extras::int
	from
		co_fixed cf
left join (
select
	order_id,
	pizza_id,
	unnest(string_to_array(exclusions,', ')) exclusions ,
	unnest(string_to_array(extras,', ')) extras 
from
	co_fixed cf) k on k.order_id = cf.order_id 
) k
left join pizza_toppings pt on pt.topping_id = k.exclusions
left join pizza_toppings pt2 on pt2.topping_id = k.extras
order by order_id 
) k
left join pizza_names pn on pn.pizza_id = k.pizza_id
group by order_id,pizza_name
) k
;















/*Generate an alphabetically ordered comma separated ingredient list for each pizza order 
from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/


select order_id, concat(pizza_name, ':', ' ', topping_name) from (
select order_id,pizza_name, array_to_string(array_agg(topping_name), ', ') topping_name from (
select order_id, pizza_name, topping_name from (
select
	order_id,
	cf.pizza_id,
	unnest(string_to_array(toppings, ', '))::int toppings
from
	co_fixed cf
left join pizza_recipes pr on
	pr.pizza_id = cf.pizza_id
) k
left join pizza_toppings pt on pt.topping_id=k.toppings
left join pizza_names pn on pn.pizza_id=k.pizza_id	
order by topping_name	
) k
group by order_id, pizza_name
order by order_id, pizza_name	
) k
	
	
	











