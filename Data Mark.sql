

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


  
  
  
  
  
