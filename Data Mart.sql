
--1.DATA CLEANSİNG STEPS


create table clean_weekly_sales as (select
  to_date(week_date, 'DD/MM/YY') AS week_date, 
  date_part('week', to_date(week_date, 'DD/MM/YY')) AS week_number,
  date_part('month', to_date(week_date, 'DD/MM/YY')) AS month_number,
  date_part('year', to_date(week_date, 'DD/MM/YY')) AS calendar_year,
region,
platform,
segment,
customer_type,
transactions,
sales,  
  case 
  	when segment like '%1%' then 'Young Adults'
  	when segment like '%2%' then 'Middle Age'
  	when segment like '%3%' or segment like '%4%' then 'Retiress'
  	else 'Unknown'
  end as age_band,
  case 
  	when left (segment,1)='C' then 'Couples'
  	when left (segment,1)='F' then 'Families'
  	else 'Unknown'
  end as demographic,
  round((sales::numeric/transactions),2) as avg_transaction
  from weekly_sales)
  
  
  --2.DATA EXPLORATİON
  
  
  
  --What day of the week is used for each week_date value?
select distinct to_char(week_date, 'day')  from clean_weekly_sales cws 





--What range of week numbers are missing from the dataset?
select distinct week_number from clean_weekly_sales cws 
order by week_number 




--How many total transactions were there for each year in the dataset?
select calendar_year,  count(transactions) total_transactions  from clean_weekly_sales cws 
group by calendar_year 
order by calendar_year 


--What is the total sales for each region for each month?
select month_number, sum(sales), region from clean_weekly_sales cws 
group by region, month_number 
order by region



--What is the total count of transactions for each platform
select platform, count(transactions) from clean_weekly_sales cws 
group by platform 



--What is the percentage of sales for Retail vs Shopify for each month?
with sales as 
(select 
		calendar_year,
		month_number,
		platform,
		sum(sales) total_sales
	from clean_weekly_sales cws 
	group by calendar_year, month_number, platform)
select 
		calendar_year, 
		month_number,
		round(100*max(case when platform='Retail' then total_sales else null end)/sum(total_sales), 2) retail_percentage,
		round(100*max(case when platform='Shopify' then total_sales else null end)/sum(total_sales), 2) shopify_percentage
from sales
group by calendar_year, month_number
order by calendar_year, month_number 







--What is the percentage of sales by demographic for each year in the dataset?
with sales as
(select 
	calendar_year,
	demographic,
	sum(sales) total_sales
	from clean_weekly_sales cws 
group by calendar_year, demographic)
select 
	calendar_year,
	round(100*max(case when demographic='Families' then total_sales else null end)/sum(total_sales),2) families_percentage,
	round(100*max(case when demographic='Couples' then total_sales else null end)/sum(total_sales),2) couples_percentage,
	round(100*max(case when demographic='Unknown' then total_sales else null end)/sum(total_sales),2) unknown_percentage
from sales
group by calendar_year





--Which age_band and demographic values contribute the most to Retail sales?
select 
	age_band,
	demographic,
	retail_sales,
	round(100*retail_sales::numeric/total_sales::numeric, 2) as contribution_percentage 
from (with sales as
(select 
	platform,
	sales,
	age_band,
	demographic
from clean_weekly_sales cws 
where platform='Retail')
select  
	age_band,
	demographic,
	sum(sales) retail_sales,
	(select sum(sales) total_sales from clean_weekly_sales cws) 
from sales 
group by age_band, demographic 
order by retail_sales) k
order by contribution_percentage desc





--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select 
	calendar_year,
	platform,
	sum(sales)/sum(transactions) avg_transaction_group,
	round(avg(avg_transaction),0) avg_transaction 
from clean_weekly_sales cws 
group by calendar_year, platform 


--3.BEFORE AND AFTER ANALYSİS

--What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
select distinct week_date, week_number from clean_weekly_sales cws 
where week_date='2020-06-15'


with changes as 
(select 
	week_date,
	week_number,
	sum(sales) total_sales
from clean_weekly_sales cws 
where week_number between 21 and 28 and calendar_year=2020
group by week_date, week_number),
changes2 as
(select 
	sum(case when week_number<=24 then total_sales else null end) before_sales,
	sum(case when week_number>24 then total_sales else null end) after_sales
from changes)
select
	*,
	after_sales-before_sales sales_difference,
	round(100*(after_sales-before_sales)/before_sales,2) percentage
from changes2





--What about the entire 12 weeks before and after?
with changes as
(select 
	sum(case when week_number<=24 then sales else null end) before_sales,
	sum(case when week_number>24 then sales else null end) after_sales
	from clean_weekly_sales cws 
where calendar_year=2020)
select
	*,
	after_sales-before_sales as sales_difference,
	round((100*((after_sales-before_sales)::numeric)/(before_sales)::numeric),2) percentage
from changes



--How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
with changes as 
(select 
	week_date,
	week_number,
	calendar_year,
	sum(sales) total_sales
from clean_weekly_sales cws 
where week_number between 21 and 28 
group by week_date, week_number, calendar_year),
changes2 as
(select 
	calendar_year,
	sum(case when week_number<=24 then total_sales else null end) before_sales,
	sum(case when week_number>24 then total_sales else null end) after_sales
from changes
group by calendar_year)
select
	*,
	after_sales-before_sales sales_difference,
	round(100*(after_sales-before_sales)/before_sales,2) percentage
from changes2








with changes as
(select
	calendar_year,
	sum(case when week_number<=24 then sales else null end) before_sales,
	sum(case when week_number>24 then sales else null end) after_sales
from clean_weekly_sales cws 
group by calendar_year 
order by calendar_year)
select
	*,
	after_sales-before_sales as sales_difference,
	round(100*((after_sales-before_sales)::numeric)/before_sales::numeric,2)
from changes









