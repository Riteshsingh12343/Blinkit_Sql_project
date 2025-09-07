create database Blinkit ;
use Blinkit ; 

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    area VARCHAR(100),
    pincode INT,
    registration_date DATE,
    customer_segment VARCHAR(50),
    total_orders INT,
    avg_order_value DECIMAL(10,2)
);


CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    promised_delivery_time DATETIME,
    actual_delivery_time DATETIME,
    delivery_status VARCHAR(50),
    order_total DECIMAL(10,2),
    payment_method VARCHAR(50),
    delivery_partner_id INT,
    store_id INT,
    FOREIGN KEY (customer_id) REFERENCES blinkit_cust(customer_id)
);



CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(10,2),
    mrp DECIMAL(10,2),
    margin_percentage DECIMAL(5,2),
    shelf_life_days INT,
    min_stock_level INT,
    max_stock_level INT
);


CREATE TABLE items (
    order_id BIGINT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES blinkit_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES blinkit_products(product_id)
);

CREATE TABLE feedback (
    feedback_id INT PRIMARY KEY,
    order_id BIGINT,
    customer_id INT,
    rating INT,
    feedback_text VARCHAR(255),
    feedback_category VARCHAR(100),
    sentiment VARCHAR(50),
    feedback_date DATE,
    FOREIGN KEY (order_id) REFERENCES blinkit_orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES blinkit_cust(customer_id)
);




CREATE TABLE performance (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(100),
    date DATE,
    target_audience VARCHAR(50),
    channel VARCHAR(50),
    impressions INT,
    clicks INT,
    conversions INT,
    spend DECIMAL(10,2),
    revenue_generated DECIMAL(10,2),
    roas DECIMAL(5,2)
);



-- Start Here 


-- List all customers with their names, email, and phone numbers.
select customer_name , email, phone 
from customer ;


-- How many total orders have been placed?
select count(*) Total_Order
from orders ;


-- Find the total number of products available.
select count(*) Total_Product
from product ;

-- Show the names and ratings of all feedback entries.
select c.customer_name 
from customer c right join feedback f  on c.customer_id = f.customer_id ;

-- List all orders placed using 'UPI' as the payment method.
Select * from orders where payment_method = "UPI" ;

-- Find the average order value for each customer.
select customer_id,(order_total) Avg_Total
from orders 
group by order_id;

-- Which product has been sold the most (by quantity)?
select i.product_id , p.product_name, sum(i.quantity) Total_quantity
from items i join product p on i.product_id = p.product_id 
group by i.product_id , p.product_name
order by Total_quantity Desc ; 

-- What is the total revenue generated per payment method?
select payment_method ,sum(order_total) As total_revenue 
from orders 
group by payment_method
order by total_revenue ;


-- List the top 5 areas with the highest number of customers.
select area , count(Customer_id)  Total_customers
from customer
group by area 
order by Total_customers Desc
limit 5 ;


-- Find all customers who have given negative feedback.
select c.customer_id , c.customer_name , f.rating , f.sentiment
from customer c join feedback f on  f.customer_id = c.customer_id 
where sentiment= "Negative" ;

-- Find the total quantity sold for each product category.
 select p.category , sum(i.quantity ) as total_quantity 
 from product p join items i on p.product_id = i.product_id 
 group by p.category 
 order by total_quantity DESC ; 
 
-- List the top 5 customers by total revenue generated.
select  c.customer_id , c.customer_name  , sum(o.order_total) as total_revenue 
from orders o join customer c on o.customer_id = c.customer_id
group by customer_id , customer_name
order by total_orders desc 
limit 5 ;
-- Which day of the week has the highest number of orders?
select dayname(order_date ) day_of_week , 
		count(order_id ) total_orders
        from orders 
        group by day_of_week
        order by total_orders desc	
        limit 5 ;
-- How many orders were delivered late?
select count(*) late_order
from orders 
where delivery_status = 'Slightly Delayed' ;
 
-- Calculate the conversion rate (conversions / clicks) for each campaign.
select campaign_name , round((conversions * 1.0 / nullif(clicks , 0 )) * 100 ,2 ) as converion_rate_performace 
from performance  ; 


-- Which city (area) has the highest average order value?
select  c.area , round(avg(o.order_total),2)avg_order
from customer c join orders o on c.customer_id = o.customer_id 
group by c.area 
order by avg_order DESC
limit 5 ;

-- List all customers who registered in 2024 and placed at least one order.
select distinct c.customer_id , c.customer_name , c.phone , c.registration_date , count(o.order_id) as Total_order 
from customer c join orders o on c.customer_id = o.customer_id
where year(c.registration_date ) = 2024
group by c.customer_id ,c.customer_name , c.phone , c.registration_date 
having count(o.order_id) >0
order by Total_orders desc ;

-- Count the number of feedback entries in each sentiment category (Positive, Neutral, Negative).
select count(feedback_category) as Total_Review
from feedback ;
-- What is the average rating for each feedback category?
select feedback_category, round(avg(rating),2) as avg_rating 
from feedback 
group by feedback_category
order by avg_rating DESC ;
-- Identify repeat customers who placed less than 10 orders.
select c.customer_id , c.customer_name , count(o.order_id) total_order
from orders o join customer c  on o.customer_id = c.customer_id 
group by c.customer_id , c.customer_name
having count(o.order_id)< 10
order by total_orders desc ; 

-- Show the number of orders per store.
 select store_id , count(order_id) as total_order
 from orders 
 group by store_id
 order by total_order desc ;
 
-- List all orders where the delivery took more than 30 minutes.
select order_id , order_date, customer_id , promised_delivery_time , actual_delivery_time ,
timestampdiff(minute , order_date,actual_delivery_time ) as delivery_time_difference 
from orders
where timestampdiff(minute , order_date, actual_delivery_time ) > 30
group by order_id, order_date, customer_id, promised_delivery_time, actual_delivery_time
order by delivery_time_difference desc ;

-- What is the total revenue generated by each brand?
select p.brand , round(sum(i.quantity * p.price) ,2) total_revenue 
from product p join items i on p.product_id = i.product_id
group by p.brand	
order by total_revenue DESC ;
-- Which campaign had the highest return on ad spend (ROAS)?
select campaign_id , campaign_name , max(roas) as highest_roas 
from performance
group by campaign_id , campaign_name 
order by highest_roas 
limit 1 ; 

-- List customers who ordered a product but gave a rating less than 3.
select c.customer_id , 
		c.customer_name ,
        f.order_id , 
        f.rating , 
        f.feedback_text 
from feedback f join customer c on f.customer_id = c.customer_id 
where f.rating < 3 
limit 5 ;


-- What is the average delivery delay (actual - promised) for each delivery partner?
select delivery_partner_id , 
round((timestampdiff(MINUTE , promised_delivery_time , actual_delivery_time )), 0 ) as Avg_delay_min
from orders 
order by Avg_delay_min desc ;


-- Show a monthly trend of orders and revenue generated.
select  date_format(order_date , '%m') As Month ,
		count(order_id) Total_order,
        sum(order_total) Total_revenue 
	
    from orders
    group by date_format(order_date , '%m')
    order by Month ;


-- Identify products that are priced significantly below their MRP (e.g., more than 30% discount).
select product_name , price , mrp , round(((price -mrp ) /mrp )* 100 ,2 ) as discounted_price  
from product
where ((mrp - price) / mrp) * 100 > 30
order by discounted_price desc ;


-- Which campaigns resulted in more than 50 conversions and ROAS > 3?
select campaign_name ,conversions , roas 
from performance
where conversions > 50 && roas > 3  ;

-- Identify customers who placed an order and gave feedback on the same day.
 select o.customer_id ,c.customer_name ,
		o.order_id  , date(o.order_date) as order_date ,
        f.feedback_id , date(f.feedback_date ) as feedback_date , f.rating 
 from orders o join feedback f on o.order_id = f.order_id
			   join customer c on c.customer_id = o.customer_id 
 where  date(o.order_date) = date(f.feedback_date)
 order by o.order_date ;
 
 
-- Which delivery partner has the fastest average delivery time?
	 select delivery_partner_id  , round(avg(timestampdiff( minute , promised_delivery_time , actual_delivery_time)),2) as delivery_time 
     from orders 
     group by delivery_partner_id 
     order by delivery_time asc 
     limit 1 ;
-- List the most common issues based on feedback text using keyword matching (e.g., 'late', 'damaged', etc.).
	select 
			case
				when feedback_text LIKE '%late%' THEN 'Late Delivery'
				WHEN feedback_text LIKE '%delay%' THEN 'Late Delivery'
				WHEN feedback_text LIKE '%damaged%' THEN 'Damaged Product'
				WHEN feedback_text LIKE '%wrong%'  THEN 'Wrong Item'
				WHEN feedback_text LIKE '%incorrect%' THEN 'Wrong Item'
				WHEN feedback_text LIKE '%rude%' OR feedback_text LIKE '%bad service%' THEN 'Bad Service'
				ELSE 'Other'
			END AS issue_type , 
            count(*) as issue_count
            from feedback
            group by issue_type
            order by issue_count ;
            
            
-- Rank customers based on lifetime value (total amount spent).
	select o.customer_id ,c.customer_name,
		   sum(o.order_total) as Lifetime_value ,
           rank() over (order by sum(o.order_total) desc) as current_rank 
           from customer c join orders o on c.customer_id = o.customer_id 
           
		group by o.customer_id , c.customer_id
        order by lifetime_value desc;
           

-- Calculate the average basket size (number of items per order).
	select round( avg(item_count),2) as Avg_basket_size 
    from (
			select order_id ,
              sum(quantity) as item_count 
              from items
              group by order_id 
              ) as Order_summary ;
-- Which product categories generate the most revenue?
	select p.category , 
			round(sum(i.quantity * i.unit_price ),2) as total_revenue 
            from items i join product p on i.product_id = p.product_id 
            group by p.category
            order by total_revenue ;
            
-- How many customers belong to each customer segment?
	select customer_segment , 
			count(*) as total_customer 
            from customer 
            group by customer_segment
            order by total_customer desc;
            
-- List all orders where the unit price of an item exceeds the product’s MRP.
  select i.order_id , i.product_id , p.product_name , i.unit_price , p.mrp 
  from items i join product p on i.product_id = p.product_id 
  where i.unit_price > p.mrp 
  order	by i.unit_price desc ; 
    
-- Identify campaigns with high spend but low conversion rates.
SELECT 
    campaign_id,
    campaign_name,
    spend,
    clicks,
    conversions,
    ROUND((conversions * 1.0 / NULLIF(clicks, 0)) * 100, 2) AS conversion_rate_percent
FROM performance
WHERE spend > 3000   
  AND (conversions * 1.0 / NULLIF(clicks, 0)) < 0.05
ORDER BY spend DESC;

-- Determine delivery success rate per store (on-time vs total deliveries).

SELECT 
    store_id,
    COUNT(order_id) AS total_deliveries,
    SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS success_rate_percent
FROM orders
GROUP BY store_id
ORDER BY success_rate_percent DESC;

-- What’s the average shelf life of products sold in each category?
SELECT 
    category,
    ROUND(AVG(shelf_life_days), 2) AS avg_shelf_life
FROM product
GROUP BY category
ORDER BY avg_shelf_life DESC;

-- Calculate the gross margin (unit_price - cost_price) per order item.
SELECT 
    i.order_id,
    i.product_id,
    p.product_name,
    i.unit_price,
    ROUND(p.price - (p.price * (p.margin_percentage / 100)), 2) AS cost_price,
    ROUND(i.unit_price - (p.price - (p.price * (p.margin_percentage / 100))), 2) AS gross_margin
FROM items i
JOIN product p ON i.product_id = p.product_id  ;

-- Track monthly customer acquisition from registration dates.
SELECT 
    DATE_FORMAT(registration_date, '%Y-%m') AS month,
    COUNT(*) AS new_customers
FROM customer
GROUP BY DATE_FORMAT(registration_date, '%Y-%m')
ORDER BY month;

-- Identify high-value feedback that mentions both rating < 3 and “delivery” in the text.
SELECT 
    feedback_id,
    customer_id,
    order_id,
    rating,
    feedback_text,
    feedback_date
FROM feedback
WHERE rating < 3 
  AND feedback_text LIKE '%delivery%';

-- Which channels (App, Email, SMS) are most efficient by ROAS?
SELECT 
    channel,
    ROUND(AVG(roas), 2) AS avg_roas
FROM performance
GROUP BY channel
ORDER BY avg_roas DESC;


