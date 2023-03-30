--we want to target the customers in the most efficient and proactive way,
-- to increase sales/revenue , improve customer retention and decrease churn.
--so first we need to check revenue and get top 10 customers in revenue 
 --In summary, this SQL query returns a list of the top 10 customers based on the revenue they generated
select distinct * from (select customer_id  ,sum(price*quantity) as revenu ,rank() over(order by sum(price*quantity)desc)as rnk
from tableretail
group by customer_id)
where rnk<=10;


 
-------no of products products purchased by each customer in each invoice and the total number of invoices for each customer.
select *
from (select distinct customer_id, invoice,invoicedate,count(stockcode) over (partition by customer_id,invoice)as no_Of_Prod ,count(invoice)
over(partition by customer_id) invoicescount
from tableretail )
order by customer_id,no_Of_Prod; 


--------------------------------------------------This query calculates the time gap between each customer's consecutive orders, i.e., the time difference between the current order and the previous order placed by the same customer.


WITH customer_orders AS (
  SELECT 
    CUSTOMER_ID, 
    TO_DATE(substr(INVOICEDATE, 1, INSTR(INVOICEDATE, ' ')), 'MM/DD/YYYY') AS ORDER_DATE,
    LAG(TO_DATE(substr(INVOICEDATE, 1, INSTR(INVOICEDATE, ' ')), 'MM/DD/YYYY'),1,TO_DATE(substr(INVOICEDATE, 1, INSTR(INVOICEDATE, ' ')), 'MM/DD/YYYY')) 
    OVER (
      PARTITION BY CUSTOMER_ID
      ORDER BY TO_DATE(substr(INVOICEDATE, 1, INSTR(INVOICEDATE, ' ')), 'MM/DD/YYYY')
    ) AS PREVIOUS_ORDER_DATE
  FROM tableretail
  group by CUSTOMER_ID, 
    TO_DATE(substr(INVOICEDATE, 1, INSTR(INVOICEDATE, ' ')), 'MM/DD/YYYY')
)

SELECT 
  CUSTOMER_ID, 
  ORDER_DATE,
  PREVIOUS_ORDER_DATE,
  ORDER_DATE - PREVIOUS_ORDER_DATE AS TIME_GAP
  
FROM customer_orders 

ORDER BY CUSTOMER_ID, ORDER_DATE;

---------------------------------------------------------------------the highest product per month-------------------------------------------------------------



WITH monthly_sales AS (
    SELECT 
        extract(YEAR from TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')) AS YEAR, 
        extract(MONTH from TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')) AS MONTH,
        STOCKCODE, 
        SUM(QUANTITY) AS TOTAL_QUANTITY,
        RANK() OVER (PARTITION BY extract(MONTH from TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')) ORDER BY SUM(QUANTITY) DESC) AS RANK
    FROM tableretail 
    GROUP BY extract(YEAR from TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')), 
             extract(MONTH from TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')), 
             STOCKCODE
)
SELECT 
    YEAR, 
    MONTH, 
    STOCKCODE, 
    TOTAL_QUANTITY
FROM monthly_sales 
WHERE RANK = 1
order by total_quantity desc;




------data from 12/1/2010 to 12/9/2011 (1 year)
--so we need to get the heighest  month  in  revenue over the year
SELECT extract(month FROM TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY ')) AS month
    ,sum(quantity * price) AS revenue 
    ,RANK() OVER (
        ORDER BY SUM(quantity * price) DESC
        ) AS month_rank
FROM tableretail
GROUP BY extract(month FROM TO_DATE(substr(INVOICEDATE,1,INSTR(INVOICEDATE, ' ')),'MM/DD/YYYY '))
ORDER BY revenue DESC;
