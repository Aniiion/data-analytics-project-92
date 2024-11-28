SELECT COUNT(customer_id) as customers_count
FROM customers c;
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
WITH tab AS (
    SELECT 
        s.sales_person_id, 
        FLOOR(SUM(s.quantity * p.price)) AS income, 
        COUNT(s.sales_person_id) AS operations
    FROM products p 
    INNER JOIN sales s USING(product_id)
    GROUP BY s.sales_person_id
)
SELECT 
    emp.first_name || ' ' || emp.last_name AS seller,
    tab.operations, 
    tab.income
FROM tab
INNER JOIN employees AS emp ON tab.sales_person_id = emp.employee_id 
ORDER BY tab.income DESC
LIMIT 10;

-- Запрос day_of_the_week_income.csv
SELECT 
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM 
    sales s
INNER JOIN 
    products p ON s.product_id = p.product_id
INNER JOIN 
    employees emp ON s.sales_person_id = emp.employee_id
GROUP BY 
    emp.first_name, emp.last_name, TO_CHAR(s.sale_date, 'Day'), EXTRACT(isodow FROM s.sale_date)
ORDER BY EXTRACT(isodow FROM s.sale_date), seller;

-- Запрос для age_groups.csv
SELECT 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+' 
    END AS age_category,
    COUNT(*) AS count
FROM 
    customers
GROUP BY 
    age_category
ORDER BY 
    MIN(age) ASC;
-- Запрос для customers_by_month.csv 
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(s.quantity * p.price) AS income
FROM 
    sales s
JOIN 
    products p ON s.product_id = p.product_id
JOIN 
    customers c ON s.customer_id = c.customer_id
GROUP BY 
    date
ORDER BY 
    date ASC;
-- Запрос для special_offer.csv 
SELECT DISTINCT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    s.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM
    customers c
JOIN sales s ON c.customer_id = s.customer_id
JOIN products p ON s.product_id = p.product_id
JOIN employees e ON s.sales_person_id = e.employee_id
WHERE
    s.sale_date = (
        SELECT MIN(s1.sale_date)
        FROM sales s1
        WHERE s1.customer_id = c.customer_id
    )
    AND p.price = 0
ORDER BY
    customer, seller;

