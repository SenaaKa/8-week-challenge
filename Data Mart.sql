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
select platform, sum(transactions) from clean_weekly_sales cws 
group by platform 



--What is the percentage of sales for Retail vs Shopify for each month?





--What is the percentage of sales by demographic for each year in the dataset?




--Which age_band and demographic values contribute the most to Retail sales?



--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?







