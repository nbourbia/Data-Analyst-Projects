# What are the different payment methods, and how many transactions and items were sold with each method?
select payment_method,
count(*) number_of_transactions
from 
walmart
group by payment_method;

#Which category received the highest average rating in each branch?
select branch,
category,
rate from
(
select branch,
category,
avg(rating) rate,
rank() over(partition by branch order by avg(rating)) the_rank
from walmart
group by 1,2
) tbl
where the_rank =1;

# What is the busiest day of the week for each branch based on transaction volume?
select * from 
(
select branch,
dayname(date_format(date,"%d/%m/%y")) day_name,
avg(rating) avg_rating,
count(*) number_of_transactions,
rank() over(partition by branch order by count(*)) the_rank
from walmart
group by 1,2
) table1
where the_rank=1;

# What are the average, minimum, and maximum ratings for each category in each city?
select city,category,
max(rating) max_rating,
min(rating) min_rating,
avg(rating) avg_rating
from walmart
group by 1,2
order by 1,2;


#What is the total profit for each category, ranked from highest to lowest?
select category, sum(total * profit_margin) total_profit from walmart
group by 1
order by 2 desc;

#What is the most frequently used payment method in each branch?
with cte
as
(select branch,
		payment_method,
        count(*) frequently_used,
        rank() over(partition by Branch order by count(*) desc) ranking
from walmart 
group by 1,2 
)
select * from cte
where ranking = 1;

#How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
with calc
as (
select *,
case
	when hour(str_to_date(time,"%H")) < 12 then "Morning"
    when hour(str_to_date(time,"%H")) between 12 and 17 then "Afternoon"
    else "Evening"
end shift
from walmart
)
select branch,shift,count(*) n_transactions from calc group by 1,2 order by 1,3 desc;

#Which branches experienced the largest decrease in revenue compared to the previous year?
with revenue_2022
as (
select branch,
sum(total) Total_past_revenue
from walmart
where year(date_format(date,"%d/%m/%y"))= 2022
group by branch
),
revenue_2023
as (
select branch,
sum(total) Total_curr_revenue
from walmart
where year(date_format(date,"%d/%m/%y"))= 2023
group by branch)
select *,
round((revenue_2022.Total_past_revenue - revenue_2023.Total_curr_revenue)/revenue_2022.Total_past_revenue *100,2) Ratio from 
revenue_2022 
join 
revenue_2023
on revenue_2022.branch = revenue_2023.branch
where revenue_2022.Total_past_revenue > revenue_2023.Total_curr_revenue
order by Ratio desc;