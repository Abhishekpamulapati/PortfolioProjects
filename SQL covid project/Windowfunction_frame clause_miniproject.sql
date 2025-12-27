DROP TABLE product;
CREATE TABLE product
( 
    product_category varchar(255),
    brand varchar(255),
    product_name varchar(255),
    price int
);
INSERT INTO product VALUES
('Phone', 'Apple', 'iPhone 12 Pro Max', 1300),
('Phone', 'Apple', 'iPhone 12 Pro', 1100),
('Phone', 'Apple', 'iPhone 12', 1000),
('Phone', 'Samsung', 'Galaxy Z Fold 3', 1800),
('Phone', 'Samsung', 'Galaxy Z Flip 3', 1000),
('Phone', 'Samsung', 'Galaxy Note 20', 1200),
('Phone', 'Samsung', 'Galaxy S21', 1000),
('Phone', 'OnePlus', 'OnePlus Nord', 300),
('Phone', 'OnePlus', 'OnePlus 9', 800),
('Phone', 'Google', 'Pixel 5', 600),
('Laptop', 'Apple', 'MacBook Pro 13', 2000),
('Laptop', 'Apple', 'MacBook Air', 1200),
('Laptop', 'Microsoft', 'Surface Laptop 4', 2100),
('Laptop', 'Dell', 'XPS 13', 2000),
('Laptop', 'Dell', 'XPS 15', 2300),
('Laptop', 'Dell', 'XPS 17', 2500),
('Earphone', 'Apple', 'AirPods Pro', 280),
('Earphone', 'Samsung', 'Galaxy Buds Pro', 220),
('Earphone', 'Samsung', 'Galaxy Buds Live', 170),
('Earphone', 'Sony', 'WF-1000XM4', 250),
('Headphone', 'Sony', 'WH-1000XM4', 400),
('Headphone', 'Apple', 'AirPods Max', 550),
('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
('Smartwatch', 'Apple', 'Apple Watch Series 6', 1000),
('Smartwatch', 'Apple', 'Apple Watch SE', 400),
('Smartwatch', 'Samsung', 'Galaxy Watch 4', 600),
('Smartwatch', 'OnePlus', 'OnePlus Watch', 220);


select * from product

--first value
----query to display the most expensive product under each category (corresponding to each record)
select * ,first_value(product_name) over(partition by product_category order by price desc) as Exp_prod
from product

----query to display the least expensive product under each category (corresponding to each record)
---Method 1
select * ,
first_value(product_name) over(partition by product_category order by price desc) as Exp_prod,
last_value(product_name) 
		over(partition by product_category order by price asc) as lst_prod
from product

--- Method 2
select * ,first_value(product_name) 
			over(partition by product_category order by price desc) as Exp_prod,
last_value(product_name) 
		over(partition by product_category order by price desc 
			range between unbounded preceding and unbounded following) as Lst_Exp_prod
from product

--Method-3
-- Alternate way to write SQL query using Window functions
select *,
first_value(product_name) over w as Exp_prod,
last_value(product_name) over w as lst_Exp_prod
from product
WHERE product_category ='Phone'
window w as (partition by product_category order by price desc
            range between unbounded preceding and unbounded following);
            
--Nth value
---query to display the Second most expensive product under each category.
select *,
first_value(product_name) over w as Exp_prod,
last_value(product_name) over  w as lst_Exp_prod
nth_value(product_name, 5) over w as second_most_exp_product
from product

Window w as (partition by product_category order by price desc
            range between unbounded preceding and unbounded following);
----
-- NTILE
-- query to segregate all the expensive phones, mid range phones and the cheaper phones.
select z.product_name, 
case when z.buckets = 1 then 'Expensive Phones'
     when z.buckets = 2 then 'Mid Range Phones'
     when z.buckets = 3 then 'budget Phones' END as Phone_Category
from (
    select *,
    ntile(3) over (order by price desc) as buckets
    from product
    where product_category = 'Phone') z;

