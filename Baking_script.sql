use level2
#Take the overall view
select 
	ph1.customer_id,
	ph1.prod_ca,
	ph1.prod_td,
	ph1.prod_credit_card, 
	ph1.prod_app, 
	ph1.prod_secured_loan, 
	ph1.prod_upl,
	Total_CA,
	Total_TD,
	Total_CD,
	Total_APP,
	Total_loan,
	Total_upl
from prod_holding ph1
left join (
select 
	ph.customer_id, 
	round(sum(amount) over (partition by customer_id), 0) as Total_CA 
from prod_holding ph 
left join aum a 
on ph.customer_id = a.customer_id 
where prod_ca = 1) as CA 
on ph1.customer_id = CA.customer_id 
left join (
select 
	ph.customer_id, 
	round(sum(amount) over (partition by customer_id), 0) as Total_TD 
from prod_holding ph 
left join aum a 
on ph.customer_id = a.customer_id 
where prod_td = 1) as TD 
on ph1.customer_id = TD.customer_id 
left join (
select 
	ph.customer_id, 
	round(sum(amount) over (partition by customer_id), 0) as Total_CD 
from prod_holding ph 
left join aum a 
on ph.customer_id = a.customer_id 
where prod_credit_card = "1") as CD 
on ph1.customer_id = CD.customer_id 
left join (
select 
	ph.customer_id, 
	round(sum(amount) over (partition by customer_id), 0) as Total_APP 
from prod_holding ph 
left join aum a 
on ph.customer_id = a.customer_id 
where prod_app = 1) as APP 
on ph1.customer_id = APP.customer_id 
left join (
select 
	ph.customer_id,
	round(sum(amount) over (partition by customer_id), 0) as Total_loan 
from prod_holding ph 
left join aum a 
on ph.customer_id = a.customer_id
where prod_secured_loan = 1) as loan 
on ph1.customer_id = loan.customer_id 
left join (
select 
	ph.customer_id, 
	round(sum(amount) over (partition by customer_id), 0) as Total_upl
from prod_holding ph 
left join aum a
on ph.customer_id = a.customer_id 
where prod_upl = 1) as UPL 
on ph1.customer_id = UPL.customer_id


#Calculatin the matrix for the checking account and the application 
select distinct 
	Checking_Account, 
	Application,
	Checking_Account / Application as Proportion
from prod_holding ph2 
left join (
select distinct 
	customer_id, 
	count(customer_id) over () as Checking_Account 
from prod_holding ph 
where prod_ca = 1) as CA 
on ph2.customer_id =  CA.customer_id 
left join (
select distinct 
	customer_id, 
	count(customer_id) over() as Application 
from prod_holding ph 
where prod_app = 1) as CA1 
on ph2.customer_id = CA1.customer_id 
where Checking_Account is not null 
and Application is not null

#Select total customers and total amount 
select distinct 
	segment,
	count(a.customer_id) over (partition by segment) as "Total Customers",
	sum(amount) over (partition by segment) as "Total Amount"
from aum a 
left join cust c 
on a.customer_id = c.customer_id 


#Calculate the matrix for checking account and time deposit
select distinct 
	Checking_Account, 
	Time_deposit,
	Checking_Account / Time_deposit as Proportion
from prod_holding ph2 
left join (
select distinct 
	customer_id, 
	count(customer_id) over () as Checking_Account 
from prod_holding ph 
where prod_ca = 1) as CA 
on ph2.customer_id =  CA.customer_id 
left join (
select distinct 
	customer_id, 
	count(customer_id) over() as Time_deposit
from prod_holding ph 
where prod_td = 1) as CA1 
on ph2.customer_id = CA1.customer_id 
where Checking_Account is not null 
and Time_deposit is not null
