-- Запрос по customers_count.csv.
select count(customer_id) as customers_count
from customers c;
-- В select выводим поле customer_id, агрегируем его с помощью функции COUNT,
-- считаем общее количество покупателей, присваиваем as
-- From - выводим таблицу из которой берем данные

-- Запрос по top_10_profitable_products.csv
select
    p.product_id AS product_id ,
    FLOOR(SUM(p.price * s.quantity)) AS amount
from
    Products p
join
    Sales s ON p.product_id = s.product_id 
group by
    p.product_id 
order by 
    Amount desc
limit 10;


-- Запрос по lowest_average_income.csv
with tab AS (
    select 
        s.sales_person_id, 
        sum(s.quantity * p.price) AS income, 
        count(*) AS operations
    from products p 
    inner join sales s using(product_id)
    group by s.sales_person_id
),
average_income AS (
    select
        AVG(income / NULLIF(operations, 0)) AS avg_income
    from tab
)
select
    concat(emp.first_name, ' ', emp.last_name) AS seller,
    round(income / NULLIF(operations, 0)) AS average_income
from tab
inner join employees emp ON tab.sales_person_id = emp.employee_id
where 
    (income / NULLIF(operations, 0)) < (select avg_income from average_income)
order by average_income ASC;

-- Запрос по top_10_total_income.csv 
with tab AS (
    select
        s.sales_person_id, 
        floor(sum(s.quantity * p.price)) AS income, 
        COUNT(s.sales_person_id) AS operations
    from products p 
    inner join sales s using(product_id)
    group by s.sales_person_id
)
select
    emp.first_name || ' ' || emp.last_name AS seller,
    tab.operations, 
    tab.income
from tab
inner join employees AS emp ON tab.sales_person_id = emp.employee_id 
order by tab.income DESC
limit 10;

-- Запрос day_of_the_week_income.csv
select
    concat(emp.first_name, ' ', emp.last_name) AS seller,
    to_char(s.sale_date, 'day') AS day_of_week,
    floor(SUM(s.quantity * p.price)) AS income
from
    sales s
inner join
    products p ON s.product_id = p.product_id
inner join 
    employees emp ON s.sales_person_id = emp.employee_id
group by
    emp.first_name, emp.last_name, TO_CHAR(s.sale_date, 'day'), EXTRACT(isodow from s.sale_date)
group by extract(isodow from s.sale_date), seller;

-- Запрос для age_groups.csv
select
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+' 
    END AS age_category,
    count(*) AS age_count
from 
    customers
group by
    age_category
order by
    min(age) ASC;
-- Запрос для customers_by_month.csv 

select
    to_char(s.sale_date, 'YYYY-MM') AS selling_month,
    count(distinct c.customer_id) AS total_customers,
    floor(SUM(s.quantity * p.price)) AS income
from
    sales s
join
    products p ON s.product_id = p.product_id
join
    customers c ON s.customer_id = c.customer_id
group by
    selling_month
order by
    selling_month ASC;

-- Запрос для special_offer.csv 
select distinct
    concat(c.first_name, ' ', c.last_name) AS customer,
    s.sale_date,
    concat(e.first_name, ' ', e.last_name) AS seller
from
    customers c
join sales s ON c.customer_id = s.customer_id
join products p ON s.product_id = p.product_id
join employees e ON s.sales_person_id = e.employee_id
where
    s.sale_date = (
        select MIN(s1.sale_date)
        from sales s1
        where s1.customer_id = c.customer_id
    )
    AND p.price = 0
order by
    customer, seller;

