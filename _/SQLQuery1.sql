drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer);

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

---What is the total amount each customer spent on Skip? 
Select a.userid,SUM(b.price) AS [TOTAL spent] from sales a inner join product b on a.product_id= b.product_id

group by a.userid

--- No of times customer visited Skip on distint dates
select userid,count(distinct created_date) as distinct_days from sales group by userid

---first product purchased made by customers
select * from
(select *, RANK() over(partition by userid order by created_date Asc) rnk from sales ) x where x.rnk=1

--Most purchased item and no of times purchase made by all customers
select * from sales
select userid,count(product_id) as [No. of purchases] from sales where product_id=
(select  top 1 product_id from sales group by product_id order by count(product_id) desc)---most purchased item on menu
group by userid

---Which item was the most popular for each customer?
Select * from 
(Select *, rank() over(partition by userid order by cnt) rnk  from 
(Select userid,product_id,COUNT(product_id)cnt from sales group by userid,product_id)a)b
where rnk=1

--- item was purchased first by customer after becoming gold member?
Select d.* from
(Select c.*, rank() over(partition by userid order by created_date ASC) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b ON a.userid=b.userid and created_date>=gold_signup_date) c)d where rnk=1;

---Item was purchased just BEFORE becoming the member
Select d.* from
(Select c.*, rank() over(partition by userid order by created_date DESC) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b ON a.userid=b.userid and created_date<=gold_signup_date) c)d where rnk=1;

----What are the total orders and amount spent for each member BEFORE they became a GOLD member?
Select userid,count(created_date) order_purchased, sum(price) tot_amt_spent from
(Select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b ON a.userid=b.userid and created_date<=gold_signup_date) c 
inner join product d ON c.product_id=d.product_id)e
group by userid

---if buying each product generates points; For instance: $5= 2 points and each product has different purchasing pts
--for example p1 $5= 1 skip point
--, for p2 $10= 2 skip points
--, for p3 $5= 1 skip points   $2=1 skip point
--1)Calculate points collected by each customers and for which product most points have been till now

Select userid,sum([total points]) tot_pts_ernd from 
(Select e.*, amt/points [total points]from
(Select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(Select c.userid,c.product_id,sum(price) amt from
(Select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id) d)e )f
group by userid;

--2) Total cash earned

Select userid,sum([total points])*2.5 tot_cash_ernd from 
(Select e.*, amt/points [total points]from
(Select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(Select c.userid,c.product_id,sum(price) amt from
(Select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id) d)e )f
group by userid;

----total pts for each product

Select * from
(Select * , rank() over(order by tot_pts_ernd DESC) rnk from
(Select product_id,sum([total points]) tot_pts_ernd from 
(Select e.*, amt/points [total points]from
(Select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(Select c.userid,c.product_id,sum(price) amt from
(Select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id) d)e )f group by product_id)f)g where rnk=1;

--10. In year one after customer joining the gold program (include the date of join) irrespective 
--of what customer has purchased they earn 5 skip points for every $10 spent who earn more 1 0r 3 
--and what was their points earning for first year? 
--1 skip pt= $2
--0.5 skip pts= $1

Select c.*, d.price* 0.5 total_pts_enrd from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b ON a.userid=b.userid and created_date>=gold_signup_date 
and created_date<=DateAdd(year,1,gold_signup_date))c inner join product d ON c.product_id=d.product_id;

--11 rank all the transactions of all the customers

Select *, RANK() over(partition by userid order by created_date ASC) as rnk
from sales

--12 rank all the transctions for each member whenever they are skip gold member for every non gold member 
--transction mark as na

Select d.*,case when rnk=0 then 'na' else rnk end as rnkk from
(Select c.*,cast((case when gold_signup_date is NULL then 0 else rank() over(partition by userid order by created_date DESC) end) as varchar) as rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
left join goldusers_signup b ON a.userid=b.userid and created_date>=gold_signup_date) c)d