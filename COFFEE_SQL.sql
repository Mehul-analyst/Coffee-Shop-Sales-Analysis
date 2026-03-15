-- fixing dates
update coffee
set transaction_date = str_to_date(coffee.transaction_date , "%d-%m-%Y") ;

select product_detail , case
                            when product_detail like '%Rg%' then trim(replace(product_detail , 'Rg' , ''))
                            when product_detail like '%Lg%' then trim(replace(product_detail , 'Lg' , ''))
                            when product_detail like '%Sm%' then trim(replace(product_detail , 'Sm' , ''))
                            else trim(product_detail)
                        end as size
    from coffee ;

-- making new column for size filter
alter table coffee
add column size text ;

-- updating the size column
update coffee
set size =
case
                            when binary product_detail like '%Rg%' then 'Regular'
                            when binary product_detail like '%Lg%' then 'Large'
                            when binary product_detail like '%Sm%' then 'Small'
                            else 'Not Defined'
                        end  ;

-- now changing the product_detail
update coffee set product_detail =
case
                            when binary product_detail like '%Rg%' then trim(replace(product_detail , 'Rg' , ''))
                            when binary product_detail like '%Lg%' then trim(replace(product_detail , 'Lg' , ''))
                            when binary product_detail like '%Sm%' then trim(replace(product_detail , 'Sm' , ''))
                            else trim(product_detail)
                        end  ;





-- creating net_total column
alter table coffee
add column net_total decimal(10,3) ;


-- putting the value
update coffee
set net_total = transaction_qty * unit_price ;

-- making new column for hour
alter table coffee
add column hour int ;

-- updating the value
update coffee
set hour = hour(transaction_time) ;

-- ANALYSIS
-- hour wise orders
create view v1 as
select  hour  , sum(transaction_qty) as qty_sold_per_hour from coffee group by hour order by hour ;


-- weekly revenue
create view v2 as
select dayname(transaction_date)  as Day , sum(net_total) as Net_Day_Revenue   ,count(transaction_id) as Net_footfall
from coffee group by day  ;

-- monthly revenue
create view v3 as
select monthname(transaction_date)  as month , sum(net_total) as Net_Monthly_Revenue   from coffee group by month  ;

-- category / revenue
create view v4_ as
select product_category , round(sum(net_total)  * 100/ sum( sum(net_total)) over(),0) as percentage_distribution
from coffee group by product_category order by product_category;

-- product_type/revenue
create view v5 as
select product_type , sum(net_total) as total_by_Product_type
from coffee group by product_type order by total_by_Product_type desc limit 5 ;

-- store/revenue
create view v6 as
select store_location , sum(net_total) as per_store_total_revenue
from coffee group by store_location order by store_location ;

-- store/order_count
create view v7 as
select store_location , count(transaction_id) as per_store_total_order_count
from coffee group by store_location order by store_location  ;


-- prodcut_detail/ revenue
create view v8 as
select product_detail , sum(net_total)  as  total_sales_by_product_detail
from coffee group by product_detail order by  total_sales_by_product_detail desc limit 5   ;


-- kitchen combined
create view v9 as
select store_location , count(transaction_id) as per_store_total_order_count , sum(net_total)  as per_store_total_revenue
from coffee group by store_location order by store_location ;


-- size distribution
create view v10 as
select size , round(count(transaction_id)*100/ sum(count(transaction_id)) over() , 0) as percentage_contribution_in_orders
from coffee group by size ;


-- total sales
create view kp1 as
select sum(coffee.net_total) as Total_sales from coffee ;


 -- total footfall
create view kp2 as
select count(transaction_id) as Total_footfall from coffee ;


-- total footfall
create view kp3 as
select  round(sum(coffee.net_total) /count(transaction_id) , 2) as Avg_bill_per_person from coffee ;

-- avg order per person
create view kp4 as
select  round(sum(transaction_qty) /count(distinct (transaction_id)) , 2) as Avg_order_per_person from coffee ;

-- slicer 1
create view sli1 as
select left(daysofweek , 3) as dayofweek from (select distinct(dayname(coffee.transaction_date))
    as daysofweek from coffee) as t  ;


-- slicer 2
create view sli2 as
select left(daysofweek , 3) as monthofyear from (select distinct(monthname(coffee.transaction_date))
as daysofweek from coffee) as t  ;

alter table coffee
add column dayname varchar(50) ;


update coffee
set dayname = dayname(transaction_date) ;

alter table coffee
add column month_name varchar(15) ;

update coffee set month_name =  left(monthname(transaction_date)  , 3 )  ;

