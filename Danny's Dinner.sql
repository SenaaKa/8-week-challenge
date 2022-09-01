--What is the total amount each customer spent at the restaurant?
select * from menu;
select customer_id, sum(price) from (select * from sales
join menu on menu.product_id=sales.product_id) k
group by customer_id

--How many days has each customer visited the restaurant?
select customer_id, count(distinct (order_date)) from sales
group by customer_id




--What was the first item from the menu purchased by each customer?
select * from members m;
select * from menu m;
select customer_id, product_name from (select customer_id, order_date, product_name, row_number() over(partition by customer_id order by order_date) as numbers from sales
join menu on menu.product_id=sales.product_id ) k where numbers = 1 





--What is the most purchased item on the menu and how many times was it purchased by all customers?
select * from menu m ;
select product_name, count(product_name) as numbers from sales s 
join menu on menu.product_id=s.product_id 
group by product_name





--Which item was the most popular for each customer?
select * from menu m ;
select * from (select customer_id, product_name, "number", dense_rank() over(partition by customer_id order by number desc) as numbers from (select customer_id, product_name, count(product_name) as number from sales s 
join menu on menu.product_id=s.product_id 
group by customer_id, product_name
order by number desc) k) k where numbers = 1





--Which item was purchased first by the customer after they became a member?
select * from menu m;
select distinct customer_id, product_name from (select *, dense_rank() over(partition by customer_id order by order_date) as numbers from (select members.customer_id, order_date, product_name, join_date from sales s 
left join menu on menu.product_id=s.product_id 
left join members on members.customer_id=s.customer_id) k
where order_date>join_date) k
where numbers = 1







--Which item was purchased just before the customer became a member?
select * from (select distinct customer_id,order_date,join_date,product_name, dense_rank() over(partition by customer_id order by order_date desc) as numbers from (select m.customer_id,order_date,menu.product_id,join_date,product_name from sales
left join members m on m.customer_id=sales.customer_id 
left join menu on menu.product_id=sales.product_id 
where order_date<join_date
order by order_date desc) k) k
where numbers=1











--What is the total items and amount spent for each member before they became a member?
select m.customer_id, sum(price)  from members m 
join sales s on m.customer_id=s.customer_id 
join menu on menu.product_id=s.product_id 
where join_date>order_date
group by m.customer_id 






--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id, sum(points) as points from (select sales.customer_id,product_name,price, case when product_name='sushi' then price*20 else price*10 end as points from sales
left join members m on m.customer_id=sales.customer_id 
join menu on menu.product_id=sales.product_id) k
group by customer_id








--In the first week after a customer joins the program (including their join date) they earn 
--2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select customer_id, sum(points) from (select *, case
	when join_date<=order_date+7 then price *20
	when product_name='sushi' then price*20
	else price*10
end as points
from (select members.customer_id,order_date,product_name,price,join_date from sales s 
join menu on menu.product_id=s.product_id 
join members on members.customer_id=s.customer_id) k) k
group by customer_id