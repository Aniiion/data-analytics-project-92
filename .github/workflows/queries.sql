select COUNT(customer_id) as customers_count
from customers c;
-- В select выводим поле customer_id, агрегируем его с помощью функции COUNT,
-- считаем общее количество покупателей, присваиваем as
-- From - выводим таблицу из которой берем данные


-- Запрос по lowest_average_income.csv
WITH tab AS (
    SELECT 
        s.sales_person_id, 
        SUM(s.quantity * p.price) AS income, 
        COUNT(*) AS operations
    FROM products p 
    INNER JOIN sales s USING(product_id)
    GROUP BY s.sales_person_id
),
average_income AS (
    SELECT 
        AVG(income / NULLIF(operations, 0)) AS avg_income
    FROM tab
)

SELECT 
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    ROUND(income / NULLIF(operations, 0)) AS average_income
FROM tab
INNER JOIN employees emp ON tab.sales_person_id = emp.employee_id
WHERE 
    (income / NULLIF(operations, 0)) < (SELECT avg_income FROM average_income)
ORDER BY average_income ASC;

-- Запрос по top_10_total_income.csv 
with tab as(
select s.sales_person_id, p.product_id, SUM(s.quantity * p.price) as income, 
COUNT(s.sales_person_id) as operations
from products p 
inner join sales s 
USING(product_id)
group by p.product_id, s.sales_person_id
)
select CONCAT(emp.first_name || emp.last_name) as seller,
tab.operations, tab.income
from tab
inner join employees as emp
on tab.sales_person_id = emp.employee_id 
group by seller, tab.income, tab.operations
order by income desc
limit 10;
