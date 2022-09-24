
--How many unique nodes are there on the Data Bank system?
select count(distinct node_id) from customer_nodes cn 

select * from customer_nodes cn 

--What is the number of nodes per region?
select region_id , count(distinct node_id) from customer_nodes cn 
group by region_id ;




--How many customers are allocated to each region?
select region_id,count(distinct customer_id)  from customer_nodes cn 
group by region_id 



--How many days on average are customers reallocated to a different node?
select  avg(end_date-start_date) as different from customer_nodes cn 
where end_date != '9999-12-31'



--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



--What is the unique count and total amount for each transaction type?
select txn_type, count(distinct txn_amount), sum(txn_amount) from customer_transactions ct 
group by txn_type 



--What is the average total historical deposit counts and amounts for all customers?
select customer_id, count(txn_amount), round(avg((txn_amount)),0) from customer_transactions ct 
where txn_type ='deposit'
group by customer_id 
order by customer_id 


For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
What is the closing balance for each customer at the end of the month?
What is the percentage of customers who increase their closing balance by more than 5%?








