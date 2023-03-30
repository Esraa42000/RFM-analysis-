-- First sub query that prepares the pre calculation data:
-- 1- Days since last order which will be used to calculate R score (recnecy)
-- 2- Number of orders which is used to calculate F score (frequency)
-- 3- Monetary value which consists of the sum of quantity * price of each item ( m score )

with rfm_analysis as(
select  customer_id,round(
abs((select max(TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY '))from tableretail)-
 max(TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')))) as recency
 ,count(distinct invoice) as Frequency,
 sum(quantity*price) as monetary
from tableretail where customer_id is not null  and price>0
group by customer_id ),

calc_score as(
select customer_id,recency,Frequency,monetary,NTILE(5) over(order by  recency ) as r_score,
NTILE(5) over(order by  Frequency ) as f_score,
NTILE(5) over(order by  monetary ) as m_score,
round((NTILE(5) over(order by  monetary ) +NTILE(5) over(order by  Frequency )) /2,0) as fm_score
from rfm_analysis
)
select customer_id,recency,Frequency,monetary,r_score, fm_score ,
 CASE WHEN (r_score = 5 AND fm_score = 5) 
            OR (r_score = 5 AND fm_score = 4) 
            OR (r_score = 4 AND fm_score = 5) 
        THEN 'Champions'
        WHEN (r_score = 5 AND fm_score =3) 
            OR (r_score = 4 AND fm_score = 4)
            OR (r_score = 3 AND fm_score = 5)
            OR (r_score = 3 AND fm_score = 4)
        THEN 'Loyal Customers'
        WHEN (r_score = 5 AND fm_score = 2) 
            OR (r_score = 4 AND fm_score = 2)
            OR (r_score = 3 AND fm_score = 3)
            OR (r_score = 4 AND fm_score = 3)
        THEN 'Potential Loyalists'
        WHEN r_score = 5 AND fm_score = 1 THEN 'Recent Customers'
        WHEN (r_score = 4 AND fm_score = 1) 
            OR (r_score = 3 AND fm_score = 1)
        THEN 'Promising'
        WHEN (r_score = 3 AND fm_score = 2) 
            OR (r_score = 2 AND fm_score = 3)
            OR (r_score = 2 AND fm_score = 2)
        THEN 'Customers Needing Attention'
     
        WHEN (r_score = 2 AND fm_score = 5) 
            OR (r_score = 2 AND fm_score = 4)
            OR (r_score = 1 AND fm_score = 3)
            OR(r_score=2 And fm_score=1)
        THEN 'At Risk'
        WHEN (r_score = 1 AND fm_score = 5)
            OR (r_score = 1 AND fm_score = 4)        
        THEN 'Cant Lose Them'
        WHEN r_score = 1 AND fm_score = 2 THEN 'Hibernating'
        WHEN r_score = 1 AND fm_score = 1 THEN 'Lost'
        END AS cust_segment 
from calc_score;




