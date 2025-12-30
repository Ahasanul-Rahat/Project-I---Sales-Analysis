set global sql_mode='';
create table mnz
(
 transactions_id BIGINT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id BIGINT,
    gender ENUM('Male','Female','Other'),
    age TINYINT UNSIGNED NULL,   -- allow NULL
    category VARCHAR(100),
    quantiy INT UNSIGNED,
    price_per_unit DECIMAL(10,2),
    cogs DECIMAL(10,2),
    total_sale DECIMAL(12,2)
);
LOAD DATA INFILE
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\SQL - Retail Sales Analysis_utf .csv'
INTO TABLE mnz
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(transactions_id, sale_date, sale_time, customer_id, gender, @age, category, @quantiy, @price_per_unit, @cogs, @total_sale)
SET
    age = NULLIF(@age,''),
    quantiy = NULLIF(@quantiy,''),
    price_per_unit = NULLIF(@price_per_unit,''),
    cogs = NULLIF(@cogs,''),
    total_sale = NULLIF(@total_sale,'');

-- null values
select *
from mnz
where price_per_unit is null
or cogs is null
or total_sale is null
or age is null
order by age;

select * from mnz;

														-- Data Exlporation
-- distinct category
select distinct category
from mnz; -- 3 distinct category

-- how many slaes we have
select count(*) as 'total sale' from mnz; -- 2000 sale

-- how many unique customers we have?
select count(distinct customer_id) as 'total Customer' from mnz; -- 155 unique customers

SET SQL_SAFE_UPDATES = 0;
-- delete null values
delete from mnz
where price_per_unit is null
or cogs is null
or total_sale is null;

															-- Data Analysis & Business Key Problems & Ans
-- Write a SQL query to retrieve all columns for sales made on '2022-11-05:
select * from mnz
where sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
select * -- category, sum(quantiy) -- 1785
from mnz
where category = 'Clothing'
	and sale_date like '2022%-11%'
group by 1;

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category.:
select category, sum(total_sale) as 'net sale', count(*) as 'total orders'
from mnz
group by 1;

-- 4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
select category, avg(age) as 'avg age'
from mnz
where category = 'beauty'
group by 1;

-- 5.Write a SQL query to find all transactions where the total_sale is greater than 1000.: 
select * from mnz
where total_sale >= 2000;

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
select category, gender, count(*) as total_transaction
from mnz
group by category, gender
order by category;

-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
select distinct year(sale_date) as sale_year from mnz
order by sale_year;

select * 
from(
	select 
		year(sale_date) as year,
		month(sale_date) as month, avg(total_sale) as 'avg total sale',
		rank() over(
					partition by year(sale_date)
                    order by avg(total_sale) desc
                    ) as Rankee
	from mnz
	group by 1, 2 -- or year(sale_date), month(sale_date)
) t
where Rankee = 1;

-- 8. Write a SQL query to find the top 5 customers based on the highest total sales 
select  count(distinct customer_id) from mnz; -- 155 distinct customer id

select customer_id,
		sum(total_sale) as total_sales
from mnz
group by 1
order by 2 desc
limit 5;

-- 9. Write a SQL query to find the number of unique customers who purchased items from each category.
select category,count(distinct customer_id) as 'Distinct Customer ID', count(customer_id) as 'Transaction by Customer ID'
from mnz
group by 1;

-- 10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

with hourly_sale
as
(
select *,
	case
		when hour(sale_time) < 12 then 'morning'
        when hour(sale_time) between 12 and 17 then 'afternoon'
        else 'evening'
	end as shift
from mnz
)
select
	shift,
    count(*) as total_orders
from hourly_sale
group by shift
order by total_orders;

-- END of Project 1