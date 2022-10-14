use shopping;
# Find the average time a premium and regular customers spend on the website
select c.customer_type, avg(cs.time_spent) from  customer as c inner join click_stream as cs on c.customer_id = cs.customer_id 
group by c.customer_type;
---------------------------------------------
# Get the top 5 ranked customers based on  max orders from both premium and regular category
SELECT * FROM (
WITH top as (
select c.Customer_id , c.customer_type,   count(order_id) as order_count 
from customer  as c left join orders as o on c.customer_id = o.customer_id group by c.customer_id order by order_count desc 
)
select *, DENSE_RANK() over(partition by customer_type order by order_count desc) as top_Category from top ) AS final
where top_Category <=3;

----------------------------------------------------------------------------------
# Categorize the rating into 3 groups and identify the prodcts with high/neutral/low sentiment based on their average rating
Select * , case 
when Average_Rating >4 then 'High Sentiment'
WHEN Average_Rating >=3 and Average_Rating <4  then 'Neutral Sentimennt'
ELSE 'Negative Sentiment'
END AS Sentiment
FROM
(
select p.Product_id, p.P_name, p.selling_price, avg(r.rating) as Average_Rating from product as p, reviews as r 
where p.product_id = r.product_id group by p.product_id ) as a order by Average_Rating desc;

------------------------------------------------------
# Find the average delivery time across all the orders form premium and regular customers across the shipping type
select c.customer_type, s.s_type, avg(datediff(o.shipping_Date, o.order_date)) as Average_Delivery_Days from orders as o 
left join customer as c on o.customer_id = c.customer_id
left join shipper as s on o.shipper_id = s.shipper_id 
group by c.customer_type,s.s_type ;

--------------------------------------------------------
# Total revenue to the company for the fiscal year 2021-2022 with each individual contribution
select *, round(Revenue/Total_revenue *100,2) as Contribution from (
select customer_id,  sum(Total_Cost - Total_tax - Total_Discount )  as Revenue,  sum(sum(Total_Cost - Total_tax - Total_Discount )) over() as Total_Revenue
from orders group by customer_id order by Revenue desc) as a;  